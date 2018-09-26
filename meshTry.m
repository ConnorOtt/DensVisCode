clc; clear; close all;

% Generate a unit sphere


theta=linspace(0,2*pi,1000);
phi=linspace(0,pi,1000);
color = linspace(0, 6*pi, 1000);
[theta,phi]=meshgrid(theta,phi);
[colorX, colorY] = meshgrid(color, color);

% figure
% hold on; grid on;
% plot(colorX(1, :));
% plot(colorY(:, 1));

errInpX = 1 + 0.05*cos(linspace(0, 100*pi, 1000));
errInpY = 1 + 0.05*sin(linspace(0, 100*pi, 1000));
radMat = meshgrid(errInpX, errInpY);

% col = rand(1000, )

% inp = linspace(0, 20*pi, 1000);
% rho= 1 + 0.01*sin(inp);
x = radMat.*sin(phi).*cos(theta);
y = radMat.*sin(phi).*sin(theta);
z = radMat.*cos(phi);
c = sin(colorX) + cos(colorY);

figure
hold on; grid on; grid minor;
p1 = mesh(x,y,z,c);
set(p1,'FaceAlpha',0);
% daspect([1, 1, 1])
% p2 = plot3(px,py,rho*cos(pPhi),'ro');
% set(p2,'MarkerFaceColor','red','LineStyle','-','LineWidth',2);
