function R = read_dicom_ir(filename,philips_slope_adjust,ifplot)
%
%  Read DICOM file and return 
%  data structure containing raw experimental data (IR)
%
%  R.filename - DICOM filename
%  R.D - image stack
%  R.U - DICOM image and metadata
%
%  R.L - scan slice locations
%  R.T - T_i values
%

if( nargin < 3 ), ifplot = 0; end
if( nargin < 2 ), philips_slope_adjust = 2; end

R.filename = filename;

NS = 1;

%%D = zeros(256,256,NS);
T = zeros(NS,1);

for i = 1:NS
  X = dicomread(filename);
  P = dicominfo(filename);
  vendor = P.Manufacturer;
  if( vendor(1:7) == 'Philips' )
    if( philips_slope_adjust == 1 )
    X = double(X) * double(P.RescaleSlope) + double(P.RescaleIntercept);
    end
    if( philips_slope_adjust == 2 )
    X = (double(X) - double(P.Private_2005_100d)) / double(P.Private_2005_100e);
    end
  end
  U{i}.X = X;
  U{i}.P = P;
  D(:,:,i) = X;
  T(i) = P.InversionTime;
  L(i) = P.SliceLocation;
  if( ifplot == 1 )
    figure(200+i)  
    imagesc(double(X))
    title('DICOM')
    colormap(gray)
    colormap(jet)
    colorbar
  end
end
  
size(D);

% sort T_i values
[Ts, idx] = sort(T,'descend');
%[Ts, idx] = sort(T);

T = T(idx);
L = L(idx);
D = D(:,:,idx);
%%U = U{idx};

R.D = D;
R.U = U;
R.T = T;
R.L = L;

end

