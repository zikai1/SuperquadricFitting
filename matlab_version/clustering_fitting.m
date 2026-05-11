function [x] = clustering_fitting(point,deformable)

% Optimization settings
options = optimoptions('lsqnonlin', 'Algorithm', 'trust-region-reflective', 'Display', 'off', 'MaxIterations', 1);


% Initialization SQ parameters
[t0,scale,point,point_rot0,x0]=SQ_init(point, ones(1,size(point,2)),false);

% Set lower and upper bounds for the superquadrics
upper = 4 * max(max(abs(point)));
lb = [0.0 0.0 0.001 0.001 0.001 -2*pi -2*pi -2*pi -ones(1, 3) * upper];
ub = [2.0 2.0 ones(1, 3) * upper  2*pi 2*pi 2*pi ones(1, 3) * upper];


% Set bounding volume for the outlier space L1xL2xL3
x_rot0=point_rot0(1, :);
y_rot0=point_rot0(2, :);
z_rot0=point_rot0(3, :);
V = (max(x_rot0) - min(x_rot0)) * (max(y_rot0)- min(y_rot0)) * (max(z_rot0) - min(z_rot0));


% Set outlier probability density (uniform distribution)
p0 = 1 / V;



x = zeros(3, 11);
residue = Inf * ones(1, 3);
for i = 1 : size(x0, 1)
    [x(i, :), residue(i)]=iterFitting(point,x0(i,:),p0,V,deformable,lb,ub,options);
end
[~, idx] = min(residue);
x = x(idx, :);



% Revert scaling
x(3 : 5) = x(3 : 5) * scale;
x(9 : 11) = x(9 : 11) * scale;

% Transform back from the center of mass
x(9 : 11) = x(9 : 11) + t0';
end




function [x,cost]=iterFitting(point,x0,p0,V,deformable,lb,ub,options)


w = 0.1;  %  OutlierRatio;
iter_max =20;% MaxIterationEM;
iter_min = 5;
tolerance = 1e-3;  %ToleranceEM;
relative_tolerance = 1e-1; %RelativeTolerance;


% Initialize parameters
x = x0;
cost = 0;
sigma2 = V ^ (1 / 3) / 10;
lambda=3; % entropy regularization to enhance function convexity


% Start iteration
for iter = 1 : iter_max
    
    % Evaluating distance for building correspondence probability
    [dist] = distance_deformable(point,x,deformable);


   % Define the correspondence probability acording to the distance
   p = fuzzy_correspendence(dist, sigma2, w, p0,lambda);


    % Start optimization
    cost_func = @(x) weighted_dist(x, point, p, deformable);
    [x_n, cost_n] = lsqnonlin(cost_func, x, lb, ub, options);
    
    % Update sigma^2  according to the cost 
    sigma2_n = cost_n / (3 * sum(p)); % sigma2 has a closed-form solution

    
    % Evaluate relative cost decrease
    relative_cost = (cost - cost_n) / cost_n;   

    % Termination condition
    if (cost_n < tolerance && iter > 1) || ...
       (relative_cost < relative_tolerance ...
        && iter > iter_min)
        x = x_n;
        break
    end

     cost = cost_n;
     sigma2 = sigma2_n;
     x = x_n;
end
end