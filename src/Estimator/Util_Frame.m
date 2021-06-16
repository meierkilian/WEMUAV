classdef Util_Frame
	properties
	end

	methods
		% Constructor
		function obj = Util_Frame()
		end

		% Convert 3D vector from XYZ- to NED-frame using quaterinions
		% INPUT :
		% 		in : data to rotate, in has size Mx3 where each row is 
		%			 a vector to rotate and column 1, 2 and 3 correspond
		%			 to X, Y and Z data respectively
		% 		q1 : column vector of length M, with first body quaternion component
		% 		q2 : column vector of length M, with second body quaternion component
		% 		q3 : column vector of length M, with third body quaternion component
		% 		q4 : column vector of length M, with fourth body quaternion component
		% OUTPUT :
		%		out : rotated vectors, has same size as in 
		function out = XYZ2NED(~, in, q1, q2, q3, q4)
			quat = quaternion(q1, q2, q3, q4);
			out = rotatepoint(quat, in);
		end

		% Convert 3D vector from NED- to XYZ-frame using quaterinions
		% See XYZ2NED
		function out = NED2XYZ(obj, in, q1, q2, q3, q4)
			out = obj.XYZ2NED(in, q1, -q2, -q3, -q4);
		end

		% Infers windspeed from air speed (AS) and air craft velocity using wind triangle theory.
		% INPUT :
		% 		AS : Mx3 matrix, where each line contains a 3D AS vector in the NED frame
		%		v : Mx3 matrix, where each line contains a 3D air craft velocity vector in the NED frame
		% OUTPUT :
		% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
		function ws = getWindSpeed(~, AS, v)
			ws = v + AS;
		end


		% Computes horizontal wind speed and direction
		% INPUT :
		% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
		% OUTPUT :
		%		windHDir : column vector of length M, meteorological wind direction (azimuth of where the wind comes from)
		% 		windHMag : column vector of length M, wind speed
		% 		windVert : column vector of length M, vertical wind speed
		function [windHDir, windHMag, windVert] = getHWind(~, ws)
			windHDir = mod(atan2d(-ws(:,2), -ws(:,1)),360);
			windHMag = vecnorm(ws(:,1:2), 2, 2);
			windVert = -ws(:,3);
		end

		% Computes NED wind speed vector from horizontal wind
		% INPUT :
		%		windHDir : column vector of length M, meteorological wind direction (azimuth of where the wind comes from) [deg]
		% 		windHMag : column vector of length M, wind speed
		% 		windVert : column vector of length M, vertical wind speed
		% OUTPUT :
		% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
		function ws = getNEDWind(~, windHDir, windHMag, windVert)
            ws =  [-windHMag.*cosd(windHDir), -windHMag.*sind(windHDir), -windVert];
        end

		% Convert 3D vector from Tilt- to NED-frame using quaterinions
		% INPUT :
		% 		in : data to rotate, in has size Mx3 where each row is 
		%			 a vector to rotate and column 1, 2 and 3 correspond
		%			 to Tx, Ty and Tz data respectively
		% 		q1 : column vector of length M, with first body quaternion component
		% 		q2 : column vector of length M, with second body quaternion component
		% 		q3 : column vector of length M, with third body quaternion component
		% 		q4 : column vector of length M, with fourth body quaternion component
		% OUTPUT :
		%		out : rotated vectors, has same size as in 
		function out = Tilt2NED(obj, in, q1, q2, q3, q4)
            [~, lambda] = obj.computeTilt(q1, q2, q3, q4);
            q_tilt2XYZ = quaternion([-(yaw-lambda), zeros(size(lambda,1),2)], 'euler', 'ZYX', 'frame');
            out = obj.XYZ2NED(rotatepoint(q_tilt2XYZ, in), q1, q2, q3, q4);
        end

		% Convert 3D vector from NED- to Tilt-frame using quaterinions
        % See Tilt2NED
		function out = NED2Tilt(obj, in, q1, q2, q3, q4)            
            [~, lambda] = obj.computeTilt(q1, q2, q3, q4);
            q_XYZ2tilt = quaternion([yaw-lambda, zeros(size(lambda,1),2)], 'euler', 'ZYX', 'frame');
            out = rotatepoint(q_XYZ2tilt, obj.NED2XYZ(in, q1, q2, q3, q4));
        end

        % Compute tilt angle and direction
        % INPUT :
        % 		q1 : column vector of length M, with first body quaternion component
		% 		q2 : column vector of length M, with second body quaternion component
		% 		q3 : column vector of length M, with third body quaternion component
		% 		q4 : column vector of length M, with fourth body quaternion component
		% OUTPUT :
		% 		alpaha : tilt angle [rad], tilt is always positive, if tilt is zero 
		%				 then drone is horizontal in the local frame
		% 		lambda : tilt direction [rad] (azimuth)
        function [alpha, lambda] = computeTilt(obj, q1, q2, q3, q4)
        	zNED = obj.XYZ2NED([0 0 -1], q1, q2, q3, q4);
        	xNED = obj.XYZ2NED([1 0 0], q1, q2, q3, q4);
        	alpha = acos(-zNED(:,3));
			lambda = mod(atan2(zNED(:,2), zNED(:,1)), 2*pi);
        end
	end
end

