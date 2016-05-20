% KM_KDE_DEMO Kernel density estimation demo.
%
% This file is part of the Kernel Methods Toolbox (KMBOX) for MATLAB.
% http://sourceforge.net/p/kmbox
% Author: Steven Van Vaerenbergh (steven *at* gtas.dicom.unican.es), 2013
% Id: km_kde_demo v1.0

close all
clear all

%% PARAMETERS

N1 = 100; % number of data in data set 1
m1 = -1; % mean value
s1 = 0.1; % variance 

N2 = 500; % number of data in data set 2
m2 = 2; % mean value
s2 = 0.5; % variance 

sigma = 0.1; % bandwidth
nsteps = 100; % number of abscis points in kde

%% PROGRAM
tic

x1 = m1 + sqrt(s1)*randn(N1,1);
x2 = m2 + sqrt(s2)*randn(N2,1);
x = [x1;x2];

[xx,pp] = km_kde(x,sigma,nsteps,1.2);

toc
%% OUTPUT

figure;

[n,h] = hist(x,100);
bar(h,n/sum(n),'b','EdgeColor','b')

hold on
plot(xx,pp,'r','LineWidth',3);

legend('histogram','KDE')