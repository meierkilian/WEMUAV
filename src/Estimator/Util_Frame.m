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
		%		out : rotated vectors, has same size as in
		function out = XYZ2NED(in, q1, q2, q3, q4)
			quat = quaternion(q1, q2, q3, q4);
			out = rotatepoint(quat, in);
			out(:,3) = out(:,3) + 9.81;
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
		function [windHDir, windHMag] = getHWind(ws)
			windHDir = atan2(-ws(:,1), -ws(:,2));
			windHMag = vecnorm(-ws(:,1:2), 2, 2);
		end
	end
end

