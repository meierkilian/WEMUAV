
function [Dnasa] = old_calc_Dnasa(data , tilt, path_drag_data)
%CALC_TILT Summary of this function goes here
%   Detailed explanation goes here
% See Russel et al. (2016) : https://ntrs.nasa.gov/search.jsp?R=20160007399
% Data : https://rotorcraft.arc.nasa.gov/Publications/files/Russell_1180_Final_TM_022218.pdf
% -----> Tables C18a and C18b, pages 91-92


fid = fopen(path_drag_data.F, 'r'); % opening file
F = fread(fid,'*char');  % reading file
fclose(fid);             % closing file


fid = fopen(path_drag_data.T, 'r'); % opening file
T = fread(fid,'*char');  % reading file
fclose(fid);             % closing file

[Fx Fy Fz] = strread(F,'%*u %*u %f %f %f', 'delimiter', ' ', 'headerlines' , 1) ;
[Fthrust] = strread(T,'%*u %f', 'delimiter', ' ', 'headerlines' , 1) ; %force for one propeller

% Formula used by Russel : 
% 
% D_NASA (theta,RPM) = -cos(theta)Fx - Thrust) sin(theta)

pitch = [39.95 ; 29.94 ; 19.91 ; 9.91 ; 4.98 ; 1.98 ; 0] * 2*pi /360; %[rad]

D_NASA = [];
for i = 1:7
    D_NASA = [D_NASA ;  cos(pitch(i)) * Fx(5*i - 4 : 5*i) - (Fz(5*i - 4 : 5*i) - Fthrust) * sin(pitch(i)) ] ; 
end 


% Checking if RPM data available
if any(contains(data.Properties.VariableNames, "motRpm_LB"))
	RPM = ((data.motRpm_RF + data.motRpm_LF + data.motRpm_LB + data.motRpm_RB) / 4 ) ;
else
	RPM = 5500 * ones(length(data.Time),1);
end

%Selection od the drag force depending on the tilt angle of the STRUC 
%and the RPM of the 4 rotors averaged 

k1k1 = find(RPM <= 4500 & tilt <= 1) ;
 k1k2 = find(RPM <= 4500 & 1 < tilt & tilt <= 3.5 ) ;
 k1k3 = find(RPM <= 4500 & 3.5 < tilt & tilt <= 7.5) ;
 k1k4 = find(RPM <= 4500 & 7.5 < tilt & tilt <= 15);
 k1k5 = find(RPM <= 4500 & 15 < tilt & tilt <= 25);
 k1k6 = find(RPM <= 4500 & 25 < tilt & tilt <= 35);
 k1k7 = find(RPM <= 4500 & 35 < tilt);
 
k2k1 = find(4500 < RPM & RPM <= 5100 & tilt <= 1) ;
 k2k2 = find(4500 < RPM & RPM <= 5100 & 1 < tilt & tilt <= 3.5 ) ;
 k2k3 = find(4500 < RPM & RPM <= 5100 & 3.5 < tilt & tilt <= 7.5) ;
 k2k4 = find(4500 < RPM & RPM <= 5100 & 7.5 < tilt & tilt <= 15);
 k2k5 = find(4500 < RPM & RPM <= 5100 & 15 < tilt & tilt <= 25);
 k2k6 = find(4500 < RPM & RPM <= 5100 & 25 < tilt & tilt <= 35);
 k2k7 = find(4500 < RPM & RPM <= 5100 & 35 < tilt);
 
k3k1 = find(5100 < RPM & RPM <= 5600 & tilt <= 1) ;
 k3k2 = find(5100 < RPM & RPM <= 5600 & 1 < tilt & tilt <= 3.5 ) ;
 k3k3 = find(5100 < RPM & RPM <= 5600 & 3.5 < tilt & tilt <= 7.5) ;
 k3k4 = find(5100 < RPM & RPM <= 5600 & 7.5 < tilt & tilt <= 15);
 k3k5 = find(5100 < RPM & RPM <= 5600 & 15 < tilt & tilt <= 25);
 k3k6 = find(5100 < RPM & RPM <= 5600 & 25 < tilt & tilt <= 35);
 k3k7 = find(5100 < RPM & RPM <= 5600 & 35 < tilt);
 
k4k1 = find(5600 < RPM & RPM <= 6000 & tilt <= 1) ;
 k4k2 = find(5600 < RPM & RPM <= 6000 & 1 < tilt & tilt <= 3.5 ) ;
 k4k3 = find(5600 < RPM & RPM <= 6000 & 3.5 < tilt & tilt <= 7.5) ;
 k4k4 = find(5600 < RPM & RPM <= 6000 & 7.5 < tilt & tilt <= 15);
 k4k5 = find(5600 < RPM & RPM <= 6000 & 15 < tilt & tilt <= 25);
 k4k6 = find(5600 < RPM & RPM <= 6000 & 25 < tilt & tilt <= 35);
 k4k7 = find(5600 < RPM & RPM <= 6000 & 35 < tilt);
 
k5k1 = find(RPM > 6000 & tilt <= 1) ;
 k5k2 = find(RPM > 6000 & 1 < tilt & tilt <= 3.5 ) ;
 k5k3 = find(RPM > 6000 & 3.5 < tilt & tilt <= 7.5) ;
 k5k4 = find(RPM > 6000 & 7.5 < tilt & tilt <= 15);
 k5k5 = find(RPM > 6000 & 15 < tilt & tilt <= 25);
 k5k6 = find(RPM > 6000 & 25 < tilt & tilt <= 35);
 k5k7 = find(RPM > 6000 & 35 < tilt);
 


Dnasa = zeros(length(data.Time),1) ;
 

Dnasa(k1k7) = D_NASA(1); Dnasa(k2k7) = D_NASA(2); Dnasa(k3k7) = D_NASA(3); Dnasa(k4k7) = D_NASA(4); Dnasa(k5k7) = D_NASA(5); 
Dnasa(k1k6) = D_NASA(6); Dnasa(k2k6) = D_NASA(7); Dnasa(k3k6) = D_NASA(8); Dnasa(k4k6) = D_NASA(9); Dnasa(k5k6) = D_NASA(10); 
Dnasa(k1k5) = D_NASA(11); Dnasa(k2k5) = D_NASA(12); Dnasa(k3k5) = D_NASA(13); Dnasa(k4k5) = D_NASA(14); Dnasa(k5k5) = D_NASA(15);
Dnasa(k1k4) = D_NASA(16); Dnasa(k2k4) = D_NASA(17); Dnasa(k3k4) = D_NASA(18); Dnasa(k4k4) = D_NASA(19); Dnasa(k5k4) = D_NASA(20);
Dnasa(k1k3) = D_NASA(21); Dnasa(k2k3) = D_NASA(22); Dnasa(k3k3) = D_NASA(23); Dnasa(k4k3) = D_NASA(24); Dnasa(k5k3) = D_NASA(25);
Dnasa(k1k2) = D_NASA(26); Dnasa(k2k2) = D_NASA(27); Dnasa(k3k2) = D_NASA(28); Dnasa(k4k2) = D_NASA(29); Dnasa(k5k2) = D_NASA(30);
Dnasa(k1k1) = D_NASA(31); Dnasa(k2k1) = D_NASA(32); Dnasa(k3k1) = D_NASA(33); Dnasa(k4k1) = D_NASA(34); Dnasa(k5k1) = D_NASA(35);




end

