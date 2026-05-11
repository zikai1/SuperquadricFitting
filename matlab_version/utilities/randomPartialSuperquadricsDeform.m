function [point_partial] = randomPartialSuperquadricsDeform(x, arclength, percentage,tapering,bending)

[point] = sphericalProduct_sampling_deform(x, arclength,tapering,bending);
num_pt = size(point, 2);
num_rand = floor(num_pt * percentage);
idx = randi(num_pt);
[mIdx, ~] = knnsearch(point', point(:, idx)', 'K', num_rand);
point_partial = point(:, mIdx);

end