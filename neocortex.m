

% layers
l3 = 0;
l2 = [0 0];
l1 = [0 0 0 0];

l3 = 0.04 * rand();
l2 = 0.04 * rand(1, 2);
l1 = 0.04 * rand(1, 4);

% weights
w3 = 1;
w2 = [1 -1];
w1 = [1 -1 1 -1];

% prior
pr = 0;
%pr = 1;

% sensory input drive
%y0 = [1 0 0 0];
y0 = [0 0 0 0];

% brain state
%a = [1, 0.1, 0.1];   % alpha
%b = [1, 1, 1];       % lambda
a = [0.001, 0.1, 1];
b = [1, 1, 0.1];

% data range
dt = 1;
tau = 1.0;
r = 1:500;

% y
u31 = r;
u21 = r;
u22 = r;
u11 = r;
u12 = r;
u13 = r;
u14 = r;

% b
b31 = r;
b21 = r;
b22 = r;
b11 = r;
b12 = r;
b13 = r;
b14 = r;

% loop for time
for time = r
    % Energy function

    % Layer 1
    w0 = [1 1 1 1];
    Z1 = (y0 .* w0).^2;

    A1 = sum((l1 - Z1).^2);
    B1 = sum((l1 - pr).^2);
    E1 = a(1) * (b(1) * A1 + (1 - b(1)) * B1);


    % Layer 2

    Z2 = zeros(1, 2);
    Z2(1) = (l1(1) * w1(1) + l1(2) * w1(2))^2;
    Z2(2) = (l1(3) * w1(3) + l1(4) * w1(4))^2;

    A2 = sum((l2 - Z2).^2);
    B2 = sum((l2 - pr).^2);
    E2 = a(2) * (b(2) * A2 + (1 - b(2)) * B2);

    % Layer 3

    Z3 = (l2(1) * w2(1) + l2(2) * w2(2))^2;

    A3 = sum((l3 - Z3).^2);
    B3 = sum((l3 - pr).^2);
    E3 = a(3) * (b(3) * A3 + (1 - b(2)) * B3);

    E = [E1 E2 E3];
    %l1
    sum(E)

    %l3 = 

    %dEdZ ?
    %dZdy ?
    %dEdZ 
    %dZdy 

    % n = 6;
    % D = [0:2^n-1]';
    % B = rem(floor(D*pow2(-(n-1):0)),2);

    % dydt in the Energy function [2]

    % l1
    v2 = [0 0];
    v2(1) = w1(1) * l1(1) + w1(2) * l1(2);
    v2(2) = w1(3) * l1(3) + w1(4) * l1(4);
    
    f = l1 - Z1;
    
    % feed back drive
    zz1 = [0 0 0 0];
%     zz1(1) = (l2(1) - Z2(1))  .* v2(1) .* w1(1);
%     zz1(2) = (l2(1) - Z2(1))  .* v2(1) .* w1(2);
%     zz1(3) = (l2(2) - Z2(2))  .* v2(2) .* w1(3);
%     zz1(4) = (l2(2) - Z2(2))  .* v2(2) .* w1(4);
    v1 = l1;
    %v1 = y0;
    beta1 = 1.0 * [1 1 1 1];
    sigma1 = 0.81;
    zz1(1) = v1(1)^2 / (beta1(2) * v1(2)^2 + sigma1);
    zz1(2) = v1(2)^2 / (beta1(1) * v1(1)^2 + sigma1);
    zz1(3) = v1(3)^2 / (beta1(4) * v1(4)^2 + sigma1);
    zz1(4) = v1(4)^2 / (beta1(3) * v1(3)^2 + sigma1);
    
    % prior drive
    p = l1 - [pr pr pr pr]; 
    
    dy1dt = ...
        -a(1) * b(1) * f(1) + ...
        a(2) * b(2) * zz1(1) - ...
        a(1) * (1 - b(1)) * p(1);

    dy2dt = ...
        -a(1) * b(1) * f(2) + ...
        a(2) * b(2) * zz1(2) - ...
        a(1) * (1 - b(1)) * p(2);
    
    dy3dt = ...
        -a(1) * b(1) * f(3) + ...
        a(2) * b(2) * zz1(3) - ...
        a(1) * (1 - b(1)) * p(3);
    
    dy4dt = ...
        -a(1) * b(1) * f(4) + ...
        a(2) * b(2) * zz1(4) - ...
        a(1) * (1 - b(1)) * p(4);
    
    l1 = l1 + tau * dt * [dy1dt dy2dt dy3dt dy4dt];
    l1 = min(max(l1, 0), 1);
    
    u11(time) = l1(1);
    u12(time) = l1(2);
    u13(time) = l1(3);
    u14(time) = l1(4);
    
    b11(time) = zz1(1);
    b12(time) = zz1(2);
    b13(time) = zz1(3);
    b14(time) = zz1(4);
    
    
    % l2
    v3 = w2(1) * l2(1) + w2(2) * l2(2);
    
    f = l2 - Z2;
    
    % feed back drive
    zz2 = [0 0];
%     zz2(1) = (l3 - Z3) .* v3 .* w2(1);
%     zz2(2) = (l3 - Z3) .* v3 .* w2(2);
    beta2 = [1 1];
    sigma2 = 0.81;
    zz2(1) = v2(1)^2 / (beta2(2) * v2(2)^2 + sigma2);
    zz2(2) = v2(2)^2 / (beta2(1) * v2(1)^2 + sigma2);
    
    % prior drive
    p = l2 - [pr pr]; 
    
    dy1dt = ...
        -a(2) * b(2) * f(1) + ...
        a(3) * b(3) * zz2(1) - ...
        a(2) * (1 - b(2)) * p(1);

    dy2dt = ...
        -a(2) * b(2) * f(2) + ...
        a(3) * b(3) * zz2(2) - ...
        a(2) * (1 - b(2)) * p(2);
    
    l2 = l2 + tau * dt * [dy1dt dy2dt];
    l2 = min(max(l2, 0), 1);
    
    u21(time) = l2(1);
    u22(time) = l2(2);
    
    b21(time) = zz2(1);
    b22(time) = zz2(2);
    
    % l3
    
    f = l3 - Z3;
    
    %zz3 = (l3 - Z3) .* v3 .* w2(1);
    %zz3 = 1;
    zz3 = 0;
    
    dydt = ...
        -a(3) * b(3) * f + ...
        0 - ...
        a(3) * (1 - b(3)) * (l3 - 1); % pr = 1
    
    l3 = l3 + tau * dt * dydt;
    l3 = min(max(l3, 0), 1);
    %l3
    
    u31(time) = l3;
    b31(time) = zz3;
    
end

% y-value of all neurons
figure

subplot(3,1,1)
hold on
plot([0 r], [0 u31]);

subplot(3,1,2)
hold on
plot([0 r], [0 u21]);
plot([0 r], [0 u22]);

subplot(3,1,3)
hold on
plot([0 r], [0 u11]);
plot([0 r], [0 u12]);
plot([0 r], [0 u13]);
plot([0 r], [0 u14]);

% b-value (feedback drive)
% figure
% 
% subplot(3,1,1)
% hold on
% plot(r, b31);
% 
% subplot(3,1,2)
% hold on
% plot(r, b21);
% plot(r, b22);
% 
% subplot(3,1,3)
% hold on
% plot(r, b11);
% plot(r, b12);
% plot(r, b13);
% plot(r, b14);

% (f)

