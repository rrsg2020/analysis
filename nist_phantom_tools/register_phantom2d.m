function R = register_phantom2d(D,edge_threshold)
%
%  Register phantom based on initial ROI center guess
%
%  Input parameters:
%
%  D - image stack for edge detection
%  edge_threshold - optional threshold parameter for the edge detector
%                   must in the range [0,1], default is .1
%
%  Output parameters:
%
%  R.roi_centers_init - initial (nomimal) guess for ROI centers
%  R.roi_radius_nominal - initial (nominal) guess for ROI radius
%  R.mask_radius - initial ROI mask_radius
%
%  R.X - image for edge detection (uint)
%  R.Y - image for edge detection (double)
%  R.Z - edge detection of Y
%  R.Za - edge detection of Y (thresholded)
%
%  R.offset_x - estimated global phantom offset in x direction
%  R.offset_y - estimated global phantom offset in y direction
%
%  R.dx - detected global phantom offset in x direction
%  R.dy - detected global phantom offset in y direction
%  R.phi - - detected global phantom rotation (in radians)
%  R.phi_degrees - - detected global phantom rotation (in degrees)
%
%  R.roi_centers_geo - ROI centers via geometric edge detection
%  R.roi_radii_geo   - ROI radii via geometric edge detection
%

if( nargin < 2 ), edge_threshold = 0.1; end


% rough edge detection scheme
X = D(:,:,1);
Y = double(X);
[Za,edge_shift,Z] = edge2d(Y, edge_threshold);

nmax = size(Z,1);
mmax = size(Z,2);

gscale = 1.0;
xc = nmax/2;
yc = mmax/2;
itype = 1;

[roi_centers_init, roi_radii_init, aux_centers_init, aux_radii_init] = ...
       roi_centers_ref(gscale,xc,yc,itype);


% nominal roi_radius
roi_radius = 9.0;

% mask radius
mask_radius = roi_radius * 1.3;

aux_radius = 7 * 1.3;


% correlation analysis of the 14-sphere mask

d = zeros(nmax,mmax);
for id = 1:14
  b = cmask(nmax,mask_radius,roi_centers_init(id,1),roi_centers_init(id,2));
  d = d + b;
end

for id = 1:3
  b = cmask(nmax,aux_radius,aux_centers_init(id,1),aux_centers_init(id,2));
  d = d + b;
end

phantom_mask_init = d;


[dx, dy, phi] = image_match2d(Za,phantom_mask_init,-180:180);
phi_degrees = phi/pi*180;

Rmatr = [cos(phi) -sin(phi); sin(phi) cos(phi)];
Tmatr = [dx dy];
Omatr = [nmax/2 mmax/2];
roi_centers_new = Rmatr*(roi_centers_init' - repmat(Omatr,14,1)') + repmat(Tmatr,14,1)' + repmat(Omatr,14,1)';

roi_centers_new = roi_centers_new';

aux_centers_new = Rmatr*(aux_centers_init' - repmat(Omatr,3,1)') + repmat(Tmatr,3,1)' + repmat(Omatr,3,1)';

aux_centers_new = aux_centers_new';


nmax = size(Z,1);
mmax = size(Z,2);
d = zeros(nmax,mmax);
for id = 1:14
  b = cmask(nmax,mask_radius,roi_centers_new(id,1),roi_centers_new(id,2));
  d = d + b;
end

for id = 1:3
  b = cmask(nmax,aux_radius,aux_centers_new(id,1),aux_centers_new(id,2));
  d = d + b;
end

phantom_mask_match = d;


roi_centers_match = roi_centers_new;



roi_radii_new = roi_radii_init;

% extract all regions via geometric circle detection scheme

d = zeros(nmax);
for id = 1:14
  b = cmask(nmax,mask_radius,roi_centers_new(id,1),roi_centers_new(id,2));
  d = zeros(nmax);
  d = d + b .* Za;

  [row, col] = rowcol(d);
  data = [row col]';
  [cx,cy,r] = lsqcircle(data);
  
  roi_centers_new(id,1) = cx;
  roi_centers_new(id,2) = cy;
  roi_radii_new(id) = r;

end


% tighten the centers

for i = 1:4
d = zeros(nmax);
for id = 1:14
  if( ~isfinite(roi_centers_new(id,1)) || ~isfinite(roi_centers_new(id,2)) )
     continue;
  end
  b = cmask(nmax,mask_radius,roi_centers_new(id,1),roi_centers_new(id,2));
  d = zeros(nmax);
  d = d + b .* Za;

  [row, col] = rowcol(d);
  data = [row col]';
  [cx,cy,r] = lsqcircle(data);

  roi_centers_new(id,1) = cx;
  roi_centers_new(id,2) = cy;
  roi_radii_new(id) = r;

end
end

% adjust centers

roi_centers_new(:,1) = roi_centers_new(:,1) - edge_shift;
roi_centers_new(:,2) = roi_centers_new(:,2) - edge_shift;


R.roi_radius_nominal = roi_radius;
R.mask_radius = mask_radius;

R.roi_centers_init = roi_centers_init;
R.roi_centers_match = roi_centers_match;
R.phantom_mask_init = phantom_mask_init;
R.phantom_mask_match = phantom_mask_match;


R.X = X;
R.Y = Y;
R.Z = Z;
R.Za = Za;

R.roi_centers_geo = roi_centers_new;
R.roi_radii_geo = roi_radii_new;

R.dx = dx;
R.dy = dy;
R.phi = phi;
R.phi_degrees = phi_degrees;

end
