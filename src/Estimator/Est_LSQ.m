classdef Est_LSQ < handle
    properties
        para
        uf % Frame transformation utility
        uad % Airdensity utility 
        data
    end
    
    methods
        % TODO : comment
        function obj = Est_LSQ(para)
            obj.para = para;
            obj.uf = Util_Frame();
            obj.uad = Util_AirDensity();
        end

        function setModelFuncParam(obj, data)
            global objHdl % Workaround since function prototype of lsq model function is not very versatile
            objHdl = obj;
            obj.data = data;
        end

        function ws = getWs(obj, u_ac, rho, acPara)
            % TODO : add dependency on rho
            thrust = sum(abs(acPara.b) * [u_ac.motRpm_RF, u_ac.motRpm_LF, u_ac.motRpm_LB, u_ac.motRpm_RB].^2, 2);
            thrustNED = obj.uf.XYZ2NED([zeros(size(thrust,1),2), -thrust], u_ac.q1, u_ac.q2, u_ac.q3, u_ac.q4);
            
            aNED = obj.uf.XYZ2NED([u_ac.ax, u_ac.ay, u_ac.az], u_ac.q1, u_ac.q2, u_ac.q3, u_ac.q4);

            dragNED = thrustNED - aNED .* obj.para.cst.m;
            dragXYZ = obj.uf.NED2XYZ(dragNED, u_ac.q1, u_ac.q2, u_ac.q3, u_ac.q4);

            % TODO : check signs here...
            tasXYZ = sign(dragXYZ).*sqrt(abs(dragXYZ))./abs([acPara.Cxx, acPara.Cxx, acPara.Czz]);
            tasNED = obj.uf.XYZ2NED(tasXYZ, u_ac.q1, u_ac.q2, u_ac.q3, u_ac.q4);

            ws = obj.uf.getWindSpeed(tasNED, [u_ac.vn, u_ac.ve, u_ac.vd])';
        end

        function [acPara, debug] = doLSQ(obj)
            % TODO : change as para
            % x0 = [1.965e-5/1.784, 0.0455, 0.0421];
            x0 = [1.965e-5/1.784];
            lb = [1e-8, 0, 0.0421];
            ub = [10, 10, 0.0421];
            options = optimset('Display','final-detailed','MaxFunEvals',300, 'PlotFcns', 'optimplotresnorm');
            % [x,residual,exitflag,output] = paretosearch(@obj.modelFunc,3);
            % [x,resnorm,residual,exitflag,output] = lsqnonlin(@obj.modelFunc, x0,lb,ub,options);
            [x,residual,exitflag,output] = fminunc(@obj.modelFunc, x0);
            % debug.resnorm = resnorm;
            debug.residual = residual;
            debug.exitflag = exitflag;
            debug.output = output;
            disp("[Est_LSQ] Mean residual is : " + num2str(mean(residual)));
            disp("[Est_LSQ] Computed x is : " + num2str(x));
            acPara = obj.x2acPara(x);
        end

        function [tt, b] = estimateWind(obj, data, b)
            if any(ismember("tempRef", data.Properties.VariableNames)) ...
                    && any(ismember("pressRef", data.Properties.VariableNames)) ...
                    && any(ismember("humidRef", data.Properties.VariableNames))
                rho = obj.uad.getAirDensity(mean(data.tempRef), mean(data.pressRef), mean(data.humidRef));
            else
                rho = 1.221;
            end
            
            % obj.setModelFuncParam(data);
            
            % [acPara, debug] = obj.doLSQ();
            
            acPara = obj.x2acPara(b);
            wsNED = obj.getWs(data, rho, acPara)';

            [windHDir_est, windHMag_est, windVert_est] = obj.uf.getHWind(wsNED);

            wind = timetable(windHDir_est, windHMag_est, windVert_est, 'RowTimes', data.Time);            
            tt = synchronize(wind, data);
        end
    end

    methods(Static=true)
        function F = modelFunc(x)
            global objHdl
            
            ws_est = objHdl.getWs(objHdl.data, [], objHdl.x2acPara(x))';

            ws_ref = objHdl.uf.getNEDWind(objHdl.data.windHDir_2130cm, objHdl.data.windHMag_2130cm, objHdl.data.windVert_2130cm);

            % F = [vecnorm(ws_est - ws_ref,2,2); var(vecnorm(ws_est - ws_ref,2,2))];
            F = norm(vecnorm(ws_est - ws_ref,2,2));

            % F = F.*var(F);

        end

        function acPara = x2acPara(x)
            acPara.b = x(1);
            % acPara.Cxx = x(2);
            % acPara.Czz = x(3);
            acPara.Cxx = 0.0455;
            acPara.Czz = 0.0455;

        end
    end
end