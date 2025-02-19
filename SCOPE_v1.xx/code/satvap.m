function [es,s] = satvap(T)

%% function [es,s]= satvap(T) 
% Author: Dr. ir. Christiaan van der Tol
% Date: 2003
% Update: 26-09-2016, JT, replaced a.^B by exp(log(a)*B) for speed
%
% calculates the saturated vapour pressure at 
% temperature T (degrees C)
% and the derivative of es to temperature s (kPa/C)
% the output is in mbar or hPa. The approximation formula that is used is:
% es(T) = es(0)*10^(aT/(b+T));
% where es(0) = 6.107 mb, a = 7.5 and b = 237.3 degrees C
% and s(T) = es(T)*ln(10)*a*b/(b+T)^2

% (Campbell & Norman, 1998, p41, eq 3.8 and 3.9)

%% constants
% a           = 7.5;
% b           = 237.3;         %degrees C
% 
A                                   =   6.11;                                                            % constant [hPa] %610 Pa
B                                   =   17.502;                                                         % constant [- ] %17.27
C                                   =   240.97;                                                         % constant [C ] %237.3

%% calculations
% es          = 6.107*10.^(7.5.*T./(b+T));
% s           = es*log(10)*a*b./(b+T).^2;


% Alternatively (faster)
es                                  =   A * exp(B * T./(T + C));                                        % saturated vapor pressure [Pa] 
s                                   =   B * C * es./ ((C + T).^2);                                  	% Slope of saturation vapor pressure [Pa C-1]
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             