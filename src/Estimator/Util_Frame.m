classdef Util_Frame
	properties
	end

	methods
		function obj = Util_Frame()
		end
	end

	methods(Static = true)
		% Convert 3D vector from XYZ- to NED-frame using quaterinions
		% INPUT :
		% 		in : data to rotate, in has size Mx3 where each row is 
		%			 a vector to rotate and column 1, 2 and correspond
		%			 to X, Y and Z data respectively
		% 		q1 : column vector of length M, with first body quaternion component
		% 		q2 : column vector of length M, with second body quaternion component
		% 		q3 : column vector of length M, with third body quaternion component
		% 		q4 : column vector of length M, with fourth body quaternion component
		% OUTPUT :
		%		out : rotated vectors, has same size as in % TODO : make it a table ?
		function out = XYZ2NED(in, q1, q2, q3, q4)
			quat = quaternion(q1, q2, q3, q4);
			out = rotatepoint(quat, in);
		end


		% Convert 3D vector from NED- to XYZ-frame using quaterinions
		% See XYZ2NED
		function out = NED2XYZ(in, q1, q2, q3, q4)
			out = XYZ2NED(in, q1, -q2, -q3, -q4);
		end


		% Infers windspeed from TAS and air craft velocity using wind triangle 
		% theory.
		% INPUT :
		% 		TAS : Mx3 matrix, where each line contains a 3D TAS vector in the NED frame
		%		v : Mx3 matrix, where each line contains a 3D air craft velocity vector in the NED frame
		% OUTPUT :
		% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
		function ws = getWindSpeed(TAS, v)
			ws = v - TAS;
		end


		% Computes horizontal wind speed and direction
		% INPUT :
		% 		ws : Mx3 matrix, where each line contains a 3D wind speed vector in the NED frame
		% OUTPUT :
		%		windHDir : column vector of length M, meteorological wind direction (azimuth of where the wind comes from)
		% 		windHMag : column vector of length M, wind speed
		% 		windVert : column vector of length M, vertical wind speed
		function [windHDir, windHMag, windVert] = getHWind(ws)
			windHDir = atan2d(ws(:,1), ws(:,2));
			windHDir(windHDir < 0) = windHDir(windHDir < 0) + 360;
			windHMag = vecnorm(-ws(:,1:2), 2, 2);
			windVert = -ws(:,3);
		end


		% Convert 3D vector from NED- to TxTyTz-frame (tilt frame)
		% Inspired from Garreau
		% TODO : use quaternion instead ?
		% TODO : commenting
		function out = NED2Tilt(in, roll, pitch, yaw)
            % Computing direction
            norm_p = sqrt((cos(roll).*sin(pitch)).^2 + (sin(roll).*cos(pitch)).^2);
            p_dot_n = - cos(roll).*sin(pitch);
            lambda = acos(p_dot_n ./ norm_p);

            % "Map" direction to [0;360]
            test = sin(roll).*cos(pitch) >= 0 ;  

            rot = zeros(length(roll),1);
            rot(~test) = mod(2*pi - lambda(~test) + yaw(~test),2*pi);
            rot(test) = mod(lambda(test) + yaw(test),2*pi);

            q = quaternion([zeros(size(rot,1),2), rot], 'euler', 'XYZ', 'frame');
            out = rotatepoint(q, in);
        end

        % Convert 3D vector from TxTyTz to NED-frame 
		% Inspired from Garreau
		% TODO : use quaternion instead ?
		% TODO : commenting
		function out = Tilt2NED(in, roll, pitch, yaw)
            % Computing direction
            norm_p = sqrt((cos(roll).*sin(pitch)).^2 + (sin(roll).*cos(pitch)).^2);
            p_dot_n = - cos(roll).*sin(pitch);
            lambda = acos(p_dot_n ./ norm_p);

            % "Map" direction to [0;360]
            test = sin(roll).*cos(pitch) >= 0 ;  

            rot = zeros(length(roll),1);
            rot(~test) = mod(2*pi - lambda(~test) + yaw(~test),2*pi);
            rot(test) = mod(lambda(test) + yaw(test),2*pi);

            q = quaternion([zeros(size(rot,1),2), -rot], 'euler', 'XYZ', 'frame');
            out = rotatepoint(q, in);
        end

        % TODO : comment 
        function alpha = computeTilt(roll, pitch)
            norm_p = sqrt((cos(roll).*sin(pitch)).^2 + (sin(roll).*cos(pitch)).^2 + (cos(roll).*cos(pitch)).^2);
            p_dot_n = -cos(pitch).*cos(roll);
            alpha = acos(p_dot_n ./ norm_p);
        end
	end
end

