function [t0,scale,point,point_rot1,x0] = SQInit(point,T,deformable)

% translate to origin
point = double(point);
t0 = mean(point, 2);
point = point - t0;

% rescale
max_length = max(max(point));
scale = max_length / 10;
point = point / scale;


if deformable
        % 3 times initialization
        [eigenVector, ~] = EigenAnalysisDeformable(point, T);
        eigenVector0 = [eigenVector(:, 1), eigenVector(:, 3), cross(eigenVector(:, 1), eigenVector(:, 3))];
        eigenVector1 = [eigenVector(:, 1), eigenVector(:, 2), cross(eigenVector(:, 1), eigenVector(:, 2))];
        eigenVector2 = [eigenVector(:, 2), eigenVector(:, 3), cross(eigenVector(:, 2), eigenVector(:, 3))];
        
        point_rot0 = eigenVector0' * point;% use inverse matrix to transform points to canonical form
        point_rot1 = eigenVector1' * point;
        point_rot2 = eigenVector2' * point;

        euler0 = [rotm2eul(eigenVector0); rotm2eul(eigenVector1); rotm2eul(eigenVector2)];

        
        s0 = [median(abs(point_rot0(1, :))), median(abs(point_rot0(2, :))), median(abs(point_rot0(3, :)));
            median(abs(point_rot1(1, :))), median(abs(point_rot1(2, :))), median(abs(point_rot1(3, :)));
            median(abs(point_rot2(1, :))), median(abs(point_rot2(2, :))), median(abs(point_rot2(3, :)));];
        x0 = [ones(3, 2), s0, euler0, zeros(3, 3), zeros(3,2)];
    
else
    [EigenVector, ~] = EigenAnalysis(point);
    EigenVector0 = [EigenVector(:, 1), EigenVector(:, 3), cross(EigenVector(:, 1), EigenVector(:, 3))];
    EigenVector1 = [EigenVector(:, 1), EigenVector(:, 2), cross(EigenVector(:, 1), EigenVector(:, 2))];
    EigenVector2 = [EigenVector(:, 2), EigenVector(:, 3), cross(EigenVector(:, 2), EigenVector(:, 3))];
    
    
    euler0 =[rotm2eul(EigenVector0); rotm2eul(EigenVector1); rotm2eul(EigenVector2)];% rotation matrix to Euler angles

    % initialize scale as median along transformed axis
    point_rot0 = EigenVector0' * point;
    point_rot1 = EigenVector1' * point;
    point_rot2 = EigenVector2' * point;

   s0 = [median(abs(point_rot0(1, :))), median(abs(point_rot0(2, :))), median(abs(point_rot0(3, :)));
            median(abs(point_rot1(1, :))), median(abs(point_rot1(2, :))), median(abs(point_rot1(3, :)));
            median(abs(point_rot2(1, :))), median(abs(point_rot2(2, :))), median(abs(point_rot2(3, :)));];
   x0 = [ones(3, 2), s0, euler0, zeros(3, 3)];% Initialization as an ellipsoid surface
end
    
end




function [EigenVector, EigenValue] = EigenAnalysisDeformable(point, T)
    
A = (point.*sqrt(T)) * (point.*sqrt(T))';
B = sum(diag((point.*sqrt(T))' * (point.*sqrt(T))));
MOI = B * eye(3) - A;
[EigenVector, EigenValue] = eig(MOI);
end



function [EigenVector, EigenValue] = EigenAnalysis(point)
    CovM = point * point' ./ size(point, 2);
    [EigenVector, EigenValue] = eig(CovM);
    EigenVector = flip(EigenVector, 2);
end