function [roi_centers, roi_radii, aux_centers, aux_radii] = roi_centers_ref(gscale,xc,yc,itype)
%
%  T1 and T2 array reference masks for the NIST MRI phantom
%
%  Note: The masks have been reverse-engineered from reconstructed
%  MRI images, i.e., they are approximations to the nominal T1 and T2 arrays.
%
%  By default, the masks correspond to 256x256 images
%
%  Input parameters:
%
%  gscale - mask scaling factor, default value 1.0 
%  xc - mask x-center (in pixel units), default value 128
%  yc - mask y-center (in pixel units), default value 128
%  itype - array id, default 1
%
%  Output parameters:
%
%  roi_centers - (x,y) locations of ROI sphere centers, in pixel units
%  roi_radii - ROI sphere radii, in pixel units
%
%  aux_centers - (x,y) locations of auxiliary feature centers, in pixel units
%  aux_radii - auxiliary feature radii, in pixel units
%

  
  if( nargin < 1 ), gscale = 1.0; end

  if( nargin < 2 ), xc = 128; end
  if( nargin < 3 ), yc = 128; end

  if( nargin < 4 ), itype = 1; end

  r1 = 50;
  alpha = -2*pi*(0:9)'/10 + pi;

  x1 = xc + r1 * cos(alpha) *gscale;
  y1 = yc + r1 * sin(alpha) *gscale;

  r2 = 28;
  alpha2 = -2*pi*(0:3)'/4 + pi + pi/4;

  x2 = xc + r2 * cos(alpha2) *gscale;
  y2 = yc + r2 * sin(alpha2) *gscale;

  roi_centers = [x1 y1; x2 y2];
  roi_radii = 9 * ones(14,1) *gscale;

  if( itype == 1 )
    r3 = 59;
    alpha = -2*pi*[3 6 10]'/10 + pi + 2*pi/20;
  end

  if( itype == 2 )
    r3 = sqrt((200-128)^2+(108-128)^2);
    alpha = -2*pi*[0 1 2]'/3 + atan2(200-128,108-128);
  end
  
  aux_x = xc + r3 * cos(alpha) *gscale;
  aux_y = yc + r3 * sin(alpha) *gscale;

  aux_centers = [aux_x aux_y];
  aux_radii = 7 * ones(3,1) *gscale;
  
end
