function [E,edge_shift,Z] = edge2d(X,thr,itype)
% rough edge detection scheme in R^2

if( nargin < 3 ), itype = 1; end

if( nargin < 2 ), thr = 0.5; end

if( itype == 0 )
% Roberts cross
Dx = [-1 0; 0 1];
Dy = [0 1; -1 0];
edge_shift = 0.5;
end

if( itype == 1 )
% Roberts
Dx = [-1 1; -1 1];
Dy = [1 1; -1 -1];
edge_shift = 0.5;
end

if( itype == 2 )
% Prewitt
Dx = [-1 0 1; -1 0 1; -1 0 1];
Dy = [1 1 1; 0 0 0; -1 -1 -1];
edge_shift = 1.0;
end

if( itype == 3 )
% Sobel-Feldman
Dx = [-1 0 1; -2 0 2; -1 0 1];
Dy = [1 2 1; 0 0 0; -1 -2 -1];
edge_shift = 1.0;
end

if( itype == 4 )
% modified Sobel-Feldman
Dx = [-1 0 1; -3 0 3; -1 0 1];
Dy = [1 3 1; 0 0 0; -1 -3 -1];
edge_shift = 1.0;
end

if( itype == 5 )
% Sharr
Dx = [-47 0 47; -162 0 162; -47 0 47];
Dy = [47 162 47; 0 0 0; -47 -162 -47];
edge_shift = 1.0;
end

Gx = conv2fft(X,Dx);
Gy = conv2fft(X,Dy);
Z = sqrt((abs(Gx).^2+abs(Gy).^2))/max(max(X)) / sqrt(2);
E = 1.0*( Z > max(max(Z))*thr );

end
