function [cx,cy,r] = lsqcircle(data,method)
%
% Fit circle to data via least squares
%
% Input parameters: 
%   
% data - points in R^2, real *8 (2,m) array
% method - 'geo', 'direct', 'pratt', 'taubin', 'kanatani', default 'geo'
%
% Output parameters:
%
% cx, cy - circle center
% r - circle radius
%
%
% For geometric fit method (orthogonal distance regression):
%       min \sum_i [sqrt((x_i - cx)^2 + (y_i - cy)^2) - r]^2
%
% For direct algebraic fit method:
%       min \sum_i [(x_i - cx)^2 + (y_i - cy)^2 - r^2]^2
%
% For weighted algebraic fit method, (Pratt):
%       min \sum_i [sqrt((x_i - cx)^2 + (y_i - cy)^2) - r]^2
%       ----------------------------------------------------
%                     B^2 + C^2 - 4*A*D
%
% For weighted algebraic fit method, (Taubin):
%       min \sum_i [sqrt((x_i - cx)^2 + (y_i - cy)^2) - r]^2
%       ----------------------------------------------------
%           \sum_i [sqrt((x_i - cx)^2 + (y_i - cy)^2)]^2
%
% For weighted algebraic fit method, (Kanatani):
%       min \sum_i [sqrt((x_i - cx)^2 + (y_i - cy)^2) - r]^2
%       ----------------------------------------------------
%                            r^2
%
% References: 
%
% [1] Simple algebraic circle fit (Kasa method) I. Kasa, "A curve
%     fitting procedure and its error analysis", IEEE Trans. Inst.
%     Meas., Vol. 25, pages 8-14, (1976)
%
% [2] V. Pratt, Direct least-squares fitting of algebraic surfaces, 
%     Computer Graphics 21, 1987, 145–152.
%
% [3] G. Taubin, "Estimation Of Planar Curves, Surfaces And Nonplanar
%     Space Curves Defined By Implicit Equations, With 
%     Applications To Edge And Range Image Segmentation",
%     IEEE Trans. PAMI, Vol. 13, pages 1115-1138, (1991)
%
% [4] K. Kanatani, Cramer-Rao lower bounds for curve fitting, 
%     Graph. Models Image Proc. 60, 1998, 93–99.
%
% [5] N. Chernov and C. Lesort, Least squares fitting of circles and lines,
%     arXiv cs/0301001, 2003
%
% [6] A. Al-Sharadqah and N. Chernov, Error analysis for circle
%     fitting algorithms, https://arxiv.org/pdf/0907.0421.pdf
%
% [7] https://people.cas.uab.edu/~mosya/cl/MATLABcircle.html
%

  if( nargin < 2 ), method = 'geo'; end

  if( numel(data) == 0 )
    cx = NaN; cy = NaN; r = NaN;
    return
  end
    
  centroid = mean(data,2);
  data = bsxfun(@minus, data, centroid);

  if( strcmp(method,'geo') || strcmp(method,'odr') ),
  % geometric fit, orthogonal distance regression

    [roots,discrep] = nlscircle(data);

    cx = roots(1);
    cy = roots(2);
    r  = roots(3);

  end

  if( strcmp(method,'direct') ),
  % direct algebraic fit, Kasa method

    [n,m] = size(data);

    A = [data; ones(1,m)]';
    f = sum(data.^2,1); f = f';

    y = A\f;

    cx = y(1)/2;
    cy = y(2)/2;
    r = sqrt(y(3) + cx^2 + cy^2);

  end

  if( strcmp(method,'pratt') ),
  % Pratt fit

    [n,m] = size(data);

    z = data(1,:).^2+data(2,:).^2;
    x = data(1,:);
    y = data(2,:);
    o = ones(1,m);

    Mp = [z; x; y; o];

    [U,S,V]=svd(Mp',0);
    if (S(4,4)/S(1,1) < 1e-12)   %  singular case
      A = V(:,4);
    else                         %  regular case
      %  B = [0 0 0 -2.0; 0 1 0 0; 0 0 1 0; -2.0 0 0 0];
      Binv = [0 0 0 -0.5; 0 1 0 0; 0 0 1 0; -0.5 0 0 0];
      W = V*S*V';
      [E,D] = eig(W*Binv*W);
      [Dsort,ID] = sort(diag(D));
      Astar = E(:,ID(2));
      A = W\Astar;
    end

    coefs = A;
    coefs = coefs / coefs(1);

    cx = -coefs(2)/2;
    cy = -coefs(3)/2;
    r = sqrt(abs(coefs(4)-cx^2-cy^2));

  end

  if( strcmp(method,'taubin') ),
  % Taubin fit

    [n,m] = size(data);

    z = data(1,:).^2+data(2,:).^2;

    zm = mean(z);
    z0 = (z-zm)/(2*sqrt(zm));

    x = data(1,:);
    y = data(2,:);
    o = ones(1,m);

    Mp = [z0; x; y];
    [u,s,v] = svd(Mp');

    a = v(:,3);
    a(1) = a(1)/(2*sqrt(zm));
    a = [a; -zm*a(1)];

    coefs = a;
    coefs = coefs / coefs(1);

    cx = -coefs(2)/2;
    cy = -coefs(3)/2;
    r = sqrt(abs(coefs(4)-cx^2-cy^2));

  end

  if( strcmp(method,'kanatani') ),
  % Kanatani fit (a.k.a, "hyper" fit)

    [n,m] = size(data);

    z = data(1,:).^2+data(2,:).^2;
    x = data(1,:);
    y = data(2,:);
    o = ones(1,m);

    Mp = [z; x; y; o];

    [U,S,V]=svd(Mp',0);
    if (S(4,4)/S(1,1) < 1e-12)   %  singular case
      A = V(:,4);
    else                         %  regular case
      R = mean(Mp');
      N = [8*R(1) 4*R(2) 4*R(3) 2; 4*R(2) 1 0 0; 4*R(3) 0 1 0; 2 0 0 0];
      W = V*S*V';
      [E,D] = eig(W*inv(N)*W);
      [Dsort,ID] = sort(diag(D));
      Astar = E(:,ID(2));
      A = W\Astar;
    end

    coefs = A;
    coefs = coefs / coefs(1);

    cx = -coefs(2)/2;
    cy = -coefs(3)/2;
    r = sqrt(abs(coefs(4)-cx^2-cy^2));

  end

  cx = cx + centroid(1);
  cy = cy + centroid(2);

end


function [roots,discrep] = nlscircle(data)

  % initial guess
  [cx, cy, r] = lsqcircle(data,'direct');

  roots = [cx; cy; r];
  x = data(1,:);
  y = data(2,:);

  eps = 1e-14;
  discrep = 1e+30;
  alpha = 1;

  % tighten via least squares Newton with adaptive step control
  for i = 1:20
    [roots,discrep1,alpha,ier]=nls_circle_main(roots,discrep,alpha,x,y);
    discrep; discrep1 - discrep;
    if( abs(discrep1 - discrep) < eps*abs(discrep) ), break; end
    discrep = discrep1;
  end

end


function [roots,discrep,alpha,ier]=nls_circle_main(roots,discrep,alpha,x,y)

  ier=0;
  discrep_old = discrep;

  [f,amatr] = fun_circle(x,y,roots(1),roots(2),roots(3));

  sol=amatr\f;
  roots2=roots-alpha*sol;

  fp = fun_circle(x,y,roots2(1),roots2(2),roots2(3));

  discrep_new=norm(fp,'fro');

  % adaptive step control
  if( discrep_new > discrep_old || ~isfinite(discrep_new) ),
    alpha=alpha/4;
  else
    roots=roots2;
    alpha=alpha*4;
    discrep=discrep_new;
    if( alpha > 1 ), alpha=1; end
  end

end


function [f,g] = fun_circle(x,y,cx,cy,r)

  n = length(x);

  f = zeros(n,1);
  g = zeros(n,3);

  for i = 1:n

    f(i,1) = sqrt((x(i)-cx)^2 + (y(i)-cy)^2) - r;

    g(i,1) = -(x(i)-cx)/(sqrt((x(i)-cx)^2 + (y(i)-cy)^2));
    g(i,2) = -(y(i)-cy)/(sqrt((x(i)-cx)^2 + (y(i)-cy)^2));
    g(i,3) = -1;

  end

end

