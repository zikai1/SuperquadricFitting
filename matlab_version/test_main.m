%==========================
% Implementation of the paper of 
% A Holistic Method for Superquadric Fitting Using Unsupervised ...
% Clustering Analysis, TPAMI 2026
% Mingyang Zhao, AMSS, CAS
%==========================


close all;
clear;

addpath(genpath("H:\Code\Fitting\clusterSQ\matlab_version"));



% Generate a random superquadric
epsilon1=unifrnd(0,2);
epsilon2=unifrnd(0,2);
ax=unifrnd(0.5,3);
ay=unifrnd(0.5,3);
az=unifrnd(0.5,3);
t=unifrnd(-1,1,3,1);
r=randn(1,3);
R=r./vecnorm(r);
temp=eul2rotm(R);
alpha=unifrnd(0,2*pi);
x=[epsilon1,epsilon2,ax,ay,az,R,t'];% SQ parameter


% SQ points with partial occlusion
arclength=0.2;
percentage=0.5;
[point] = randomPartialSuperquadrics(x, arclength, percentage);


% Start fitting
tapering=0;
[x_cluster] = clustering_fitting(point,tapering);



if 1
%plot input points and the fitted superquadric
figure(1)
showPoints(point, 'Color', 'r')
hold on
showSuperquadrics(x_cluster, 'Color', [0 0 1], 'FaceAlpha', 0.7, 'Arclength', 0.05, 'Light', 1);
hold off
title('ClusterFit Superquadric');
end