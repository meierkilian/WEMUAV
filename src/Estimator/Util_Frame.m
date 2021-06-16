classdef Util_Frame
	% Utility class implementing frame transformations
	properties
	end

	methods
		function obj = Util_Frame()
			% Constructor
		end

		function out = XYZ2NED(~, in, q1, q2, q3, q4)
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
			quat = quaternion(q1, q2, q3, q4);
			out = rotatepoint(quat, in);
		end

		function out = NED2XYZ(obj, in, q1, q2, q3, q4)
			% Convert 3D vector from NED- to XYZ-frame using quaterinions
			% See XYZ2NED
			out = obj.XYZ2NED(in, q1, -q2, -q3, -q4);
		end

		function ws = getWindSpeed(~, AS, v)
			% Infers windspeed from air speed (AS) and air craft velocity using wind triangle theory.
			% INPUT :
			% 		AS : Mx3 matrix, where each line contains a 3D AS vector in the NED frame
			%		v : Mx3 matrix, where each line contains a 3D air craft velocity vector in the NED frame
			% OUTPUT :
			% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
			ws = v + AS;
		end


		function [windHDir, windHMag, windVert] = getHWind(~, ws)
			% Computes horizontal wind speed and direction
			% INPUT :
			% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
			% OUTPUT :
			%		windHDir : column vector of length M, meteorological wind direction (azimuth of where the wind comes from)
			% 		windHMag : column vector of length M, wind speed
			% 		windVert : column vector of length M, vertical wind speed
			windHDir = mod(atan2d(-ws(:,2), -ws(:,1)),360);
			windHMag = vecnorm(ws(:,1:2), 2, 2);
			windVert = -ws(:,3);
		end

		function ws = getNEDWind(~, windHDir, windHMag, windVert)
			% Computes NED wind speed vector from horizontal wind
			% INPUT :
			%		windHDir : column vector of length M, meteorological wind direction (azimuth of where the wind comes from) [deg]
			% 		windHMag : column vector of length M, wind speed
			% 		windVert : column vector of length M, vertical wind speed
			% OUTPUT :
			% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
            ws =  [-windHMag.*cosd(windHDir), -windHMag.*sind(windHDir), -windVert];
        end

		function out = Tilt2NED(obj, in, q1, q2, q3, q4)
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
            [~, lambda, yaw] = obj.computeTilt(q1, q2, q3, q4);
            q_tilt2XYZ = quaternion([-(yaw-lambda), zeros(size(lambda,1),2)], 'euler', 'ZYX', 'frame');
            out = obj.XYZ2NED(rotatepoint(q_tilt2XYZ, in), q1, q2, q3, q4);
        end

		function out = NED2Tilt(obj, in, q1, q2, q3, q4)            
			% Convert 3D vector from NED- to Tilt-frame using quaterinions
	        % See Tilt2NED
            [~, lambda, yaw] = obj.computeTilt(q1, q2, q3, q4);
            q_XYZ2tilt = quaternion([yaw-lambda, zeros(size(lambda,1),2)], 'euler', 'ZYX', 'frame');
            out = rotatepoint(q_XYZ2tilt, obj.NED2XYZ(in, q1, q2, q3, q4));
        end

        function [alpha, lambda, yaw] = computeTilt(obj, q1, q2, q3, q4)
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
        	zNED = obj.XYZ2NED([0 0 -1], q1, q2, q3, q4);
        	xNED = obj.XYZ2NED([1 0 0], q1, q2, q3, q4);
        	alpha = acos(-zNED(:,3));
			yaw = mod(atan2(xNED(:,2), xNED(:,1)), 2*pi); 
			lambda = mod(atan2(zNED(:,2), zNED(:,1)), 2*pi);
        end
	end
end

