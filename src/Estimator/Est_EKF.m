classdef Est_EKF
    properties
        para
        uf % Frame transformation utility
        ur % Russell data utility
        uad % Airdensity utility 
        kf_est
        kf_calib 
    end
    
    methods
        % TODO : comment
        function obj = Est_EKF(para)
            obj.para = para;
            obj.uf = Util_Frame();
            obj.ur = Util_Russell();
            obj.uad = Util_AirDensity();
            obj.kf_calib = extendedKalmanFilter(@obj.calibStateTransitionFcn, @obj.calibMeasurementFcn);
            obj.kf_est = extendedKalmanFilter(@obj.estStateTransitionFcn, @obj.estMeasurementFcn);
        end


        function setInitialState(obj, kf, data, isCalib)
            y_ws = obj.getMeasVect(data, 1);

            if isCalib % augmented state is estimated and wind is perectly observed
                y_aug = obj.struct2augState(obj.para.init.augState.value);
                q_aug = obj.struct2augState(obj.para.init.augState.std).^2;
                r_ws = zeros(size(y_ws));
            else % augmented state is not estimated and wind is not observed
                y_aug = [];
                q_aug = [];
                r_ws = [];
            end

            q_ws = obj.para.init.ws.std^2*ones(size(y_ws));

            kf.State = obj.subState2state(y_ws, y_aug);
            kf.StateCovariance = diag(obj.subState2state(q_ws, q_aug));
            kf.ProcessNoise = diag(obj.subState2state(q_ws, q_aug));
            kf.MeasurementNoise = diag(r_ws);
        end


        function tt = estimateWind(obj, data)
            if any(ismember("tempRef", data.Properties.VariableNames)) ...
                    && any(ismember("pressRef", data.Properties.VariableNames)) ...
                    && any(ismember("humidRef", data.Properties.VariableNames))
                rho = obj.uad.getAirDensity(mean(data.tempRef), mean(data.pressRef), mean(data.humidRef));
            else
                rho = 1.221;
            end
            
            % obj.setInitialState(obj.kf_est, data, false);

            % buffPred = nan(size(data,1),17);
            % for i = 1:size(data,1)
            %     [y_ac, ~] = obj.getMeasVect(data, i);
            %     [~, ~] = correct(obj.kf_est, y_ac);
            %     [buffPred(i,:), ~] = predict(obj.kf_est, obj, rho, obj.para.acParam);
            % end

            % wsNED = buffPred(:,11:13);
            
            [acPara, ~, ~, ~, ~] = obj.calibrate(data);
            wsNED = obj.getWs(data, rho, acPara)';

            [windHDir_est, windHMag_est, windVert_est] = obj.uf.getHWind(wsNED);

            wind = timetable(windHDir_est, windHMag_est, windVert_est, 'RowTimes', data.Time);            
            tt = synchronize(wind, data);
        end


        function [acPara, buffPred, buffPredCova, buffResid, buffResidCova] = calibrate(obj, data)
            if any(ismember("tempRef", data.Properties.VariableNames)) ...
                    && any(ismember("pressRef", data.Properties.VariableNames)) ...
                    && any(ismember("humidRef", data.Properties.VariableNames))
                rho = obj.uad.getAirDensity(mean(data.tempRef), mean(data.pressRef), mean(data.humidRef));
            else
                rho = 1.221;
            end
            
            obj.setInitialState(obj.kf_calib, data, true);

            buffPred = nan(size(data,1),7);
            buffPredCova = nan(size(data,1),7,7);
            buffResid = nan(size(data,1),3);
            buffResidCova = nan(size(data,1),3,3);
            
            for i = 1:size(data,1)
                y_ws = obj.getMeasVect(data, i);
                [buffResid(i,:), buffResidCova(i,:,:)] = residual(obj.kf_calib, y_ws, obj);
                [~, ~] = correct(obj.kf_calib, y_ws, obj);
                [buffPred(i,:), buffPredCova(i,:,:)] = predict(obj.kf_calib, data(i,:), obj, rho);
            end

            % TODO : remove magic number
            meanLength = 100;
            acPara.b = mean(buffPred(meanLength:end,4));
            acPara.Cxx = mean(buffPred(meanLength:end,5));
            acPara.Cyy = mean(buffPred(meanLength:end,6));
            acPara.Czz = mean(buffPred(meanLength:end,7));
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
    end

    methods(Static = true)
        function x_kp1 = calibStateTransitionFcn(x_k, u_ac, obj, rho)
            [~, x_aug_k] = obj.state2subState(x_k);
            
            acPara = obj.augState2struct(x_aug_k);
            [x_ws_kp1] = obj.getWs(u_ac, rho, acPara);

            x_aug_kp1 = x_aug_k;

            x_kp1 = obj.subState2state(x_ws_kp1, x_aug_kp1);
        end

        function x_kp1 = estStateTransitionFcn(x_k, obj, rho, acPara)
            % TODO : implement
            x_kp1 = x_k;
        end


        function y_k = calibMeasurementFcn(x_k, obj)
            [x_ws, ~] = obj.state2subState(x_k);
            y_k = x_ws;
        end

        function y_k = estMeasurementFcn(x_k)
            % TODO : implement
            y_k = x_k;
        end

        function [x_ws, x_aug] = state2subState(x)
            x_ws = x(1:3);
            x_aug = x(4:7);
        end

        function x = subState2state(x_ws, x_aug)
            x = [x_ws; x_aug];
        end

        function acPara = augState2struct(x_aug)
            acPara.b = x_aug(1);
            acPara.Cxx = x_aug(2);
            acPara.Cyy = x_aug(3);
            acPara.Czz = x_aug(4);
        end

        function x_aug = struct2augState(acPara)
            x_aug = nan(4,1);
            x_aug(1) = acPara.b;
            x_aug(2) = acPara.Cxx;
            x_aug(3) = acPara.Cyy;
            x_aug(4) = acPara.Czz;
        end

        function y_ws = getMeasVect(data, idx)
            y_ws = nan(3,1);

            dir = data.windHDir_2130cm(idx);
            mag = data.windHMag_2130cm(idx);
            y_ws(1) = mag*cosd(dir);
            y_ws(2) = mag*sind(dir);
            y_ws(3) = -data.windVert_2130cm(idx);
        end


        function struct = acState2struct(x)
            struct.vn = x(1);
            struct.ve = x(2);
            struct.vd = x(3);

            struct.q1 = x(4);
            struct.q2 = x(5);
            struct.q3 = x(6);
            struct.q4 = x(7);

            struct.motRpm_RF = x(8);
            struct.motRpm_LF = x(9);
            struct.motRpm_LB = x(10);
            struct.motRpm_RB = x(11);

            struct.ax = x(12);
            struct.ay = x(13);
            struct.az = x(14);
        end
    end
end
