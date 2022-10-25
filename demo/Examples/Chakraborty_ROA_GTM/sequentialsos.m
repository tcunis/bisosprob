% Region of attraction estimation for the short period GTM.

import sosfactory.sosopt.*

sosf = SosoptFactory;

%% Polynomial Dynamics
f1 = @(V,alpha,q,theta,eta,F) +1.233e-8*V.^4.*q.^2         + 4.853e-9.*alpha.^3.*F.^3    + 3.705e-5*V.^3.*alpha.*q      ...
                             - 2.184e-6*V.^3.*q.^2         + 2.203e-2*V.^2.*alpha.^3     - 2.836e-6*alpha.^3.*F.^2      ...
                             + 3.885e-7*alpha.^2.*F.^3     - 1.069e-6*V.^3.*q            - 4.517e-2*V.^2.*alpha.^2      ...
                             - 2.140e-3*V.^2.*alpha.*eta   - 3.282e-3*V.^2.*alpha.*q     - 8.901e-4*V.^2.*eta.^2        ...
                             + 9.677e-5*V.^2.*q.^2         - 2.037e-4*alpha.^3.*F        - 2.270e-4*alpha.^2.*F.^2      ...
                             - 2.912e-8*alpha.*F.^3        + 1.591e-3*V.^2.*alpha        - 4.077e-4*V.^2.*eta           ...
                             + 9.475e-5*V.^2.*q            - 1.637   *alpha.^3           - 1.631e-2*alpha.^2.*F         ...
                             + 4.903   *alpha.^2.*theta    - 4.903   *alpha.*theta.^2    + 1.702e-5*alpha.*F.^2         ...
                             - 7.771e-7*F.^3               + 1.634   *theta.^3           - 4.319e-4*V.^2                ...
                             - 2.142e-1*alpha.^2           + 1.222e-3*alpha.*F           + 4.541e-4*F.^2                ...
                             + 9.823   *alpha              + 3.261e-2*F                  - 9.807.*theta      + 4.284e-1;
% change of pitch angle
f4 = @(V,alpha,q,theta,eta,F)  q;
                      
% change of angle of attack
f2 = @(V,alpha,q,theta,eta,F) -3.709e-11*V.^5.*   q.^2     + 6.869e-11*V.*alpha.^3.*F.^3 + 7.957e-10*V.^4.*alpha.*q     ...
                             + 9.860e-9 *V.^4.*   q.^2     + 1.694e-5 *V.^3.*alpha.^3    - 4.015e-8 *V.*alpha.^3.*F.^2  ...
                             - 7.722e-12*V.*alpha.^2.*F.^3 - 6.086e-9 *alpha.^3.*F.^3    - 2.013e-8 *V.^4.*q            ...
                             - 5.180e-5 *V.^3.*alpha.^2    - 2.720e-6 *V.^3.*alpha.*eta  - 1.410e-7 *V.^3.*alpha.*q     ...
                             + 7.352e-7 *V.^3.*eta.^2      - 8.736e-7 *V.^3.*q.^2        - 1.501e-3 *V.^2.*alpha.^3     ...
                             - 2.883e-6 *V.*alpha.^3.*F    + 4.513e-9 *V.*alpha.^2.*F.^2 - 4.121e-10*V.*alpha.*F.^3     ...
                             + 3.557e-6 *alpha.^3.*F.^2    + 6.841e-10*alpha.^2.*F.^3    + 4.151e-5 *V.^3.*alpha        ...
                             + 3.648e-6 *V.^3.*eta         + 3.566e-6 *V.^3.*q           + 6.246e-6 *V.^2.*alpha.*q     ...
                             + 4.589e-3 *V.^2.*alpha.^2                                  - 6.514e-5 *V.^2.*eta.^2       ...
                             + 2.580e-5 *V.^2.*q.^2        - 3.787e-5 *V.*alpha.^3       + 3.241e-7 *V.*alpha.^2.*F     ...
                             + 2.409e-7 *V.*alpha.*F.^2    + 1.544e-11*V.*F.^3           + 2.554e-4 *alpha.^3.*F        ...
                             - 3.998e-7 *alpha.^2.*F.^2    + 3.651e-8 *alpha.*F.^3       + 4.716e-7 *V.^3               ...
                             - 3.677e-3 *V.^2*alpha        - 3.231e-4 *V.^2.*eta         - 1.579e-4 *V.^2.*q            ...
                             + 2.605e-3 *V.*alpha.^2       + 1.730e-5 *V.*alpha.*F       - 5.201e-3 *V.*alpha.*theta    ...
                             - 9.026e-9 *V.*F.^2           + 2.601e-3 *V.*theta.^2       + 3.355e-3 *alpha.^3           ...
                             - 2.872e-5 *alpha.^2.*F       - 2.134e-5 *alpha.*F.^2       - 1.368e-9 *F.^3               ...
                             - 4.178e-5 *V.^2              + 2.272e-4 *V.*alpha          - 6.483e-7 *V.*F               ...
                             - 2.308e-1 *alpha.^2          - 1.532e-3 *alpha.*F          + 4.608e-1 *alpha.*theta       ...
                             - 2.304e-1 *theta.^2          + 7.997e-7 *F.^2              - 5.210e-3 *V                  ...
                             - 2.013e-2 *alpha             + 5.744e-5 *F          + q    + 4.616e-1;
                         
% change of pitch rate                         
f3 = @(V,alpha,q,theta,eta,F) -6.573e-9*V.^5.*    q.^3     + 1.747e-6*V.^4.*q.^3         - 1.548e-4*V.^3.*q.^3          ...
                             - 3.569e-3*V.^2.*alpha.^3     + 4.571e-3*V.^2.*q.^3         + 4.953e-5*V.^3.*q             ...
                             + 9.596e-3*V.^2.*alpha.^2     + 2.049e-2*V.^2.*alpha.*eta   - 2.431e-2*V.^2.*alpha         ...
                             - 3.063e-2*V.^2.*eta          - 4.388e-3*V.^2.*q            - 2.594e-7*F.^3                ...
                             + 2.461e-3*V.^2               + 1.516e-4*F.^2               + 1.089e-2*F        + 1.430e-1;                         



%% Trim condition
v0      = 45;       % m/s
alpha0  = 0.04924; % rad
q0      = 0;       % rad/s
theta0  = 0.04924; % rad

eta0    = 0.04892; % rad
delta0  = 14.33;   % percent
            

x0 = [v0; alpha0; q0; theta0];
u0 = [eta0; delta0];

% get trim point 
f = @(x,u) [
                    f1(x(1,:),x(2,:),x(3,:),x(4,:),u(1,:),u(2,:))
                    f2(x(1,:),x(2,:),x(3,:),x(4,:),u(1,:),u(2,:))
                    f3(x(1,:),x(2,:),x(3,:),x(4,:),u(1,:),u(2,:))
                    f4(x(1,:),x(2,:),x(3,:),x(4,:),u(1,:),u(2,:))
];
[x0, u0] = findtrim(f,x0, u0);

% short period
f = @(x,u) [
                    f2(x0(1),x(1),x(2),x0(4),u0(1),u0(2))
                    f3(x0(1),x(1),x(2),x0(4),u0(1),u0(2))
];

x = polyvar(sosf,'x',2,1);

% set up dynamic system
f = f(x+[x0(2);x0(3)],u0(1));

d = ([
          convvel(20, 'm/s', 'm/s')  %range.tas.lebesgue.get('ft/s')
          convang(20, 'deg', 'rad')  %range.gamma.lebesgue.get('rad')
          convang(50, 'deg', 'rad')  %range.qhat.lebesgue.get('rad')
          convang(20, 'deg', 'rad')  %range.alpha.lebesgue.get('rad')
]);


D = diag(d(2:3))^-1;
f = subs(D*f, x, D^-1*x);

f = sosf.cleanp(f, 1e-6, 0:5);

% Jacobian matrices
A = sosf.jacob(f,x);

% polynomial shape
p = x'*x;

% epsilon polynomial
l = x'*x*1e-6;

prob = bisosprob(sosf,x);

%% Decision variables
% Lyapunov candidate
[prob,V] = polydecvar(prob,'V',monomials(x,2));

% SOS multipliers
[prob,s1] = sosdecvar(prob,'s1',monomials(x,0));
[prob,s2] = sosdecvar(prob,'s2',monomials(x,1));

% level sets
[prob,b] = decvar(prob,'b');

%% Constraints
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});

% Stable level set
prob = le(prob, gradV*f + l, s2*(V-1), {'dV'}, {'V' 's2'});
prob = ge(prob, s2, 0, {'s2'});
prob = ge(prob, V, l, {'V'});

% Inscribing ellipsoid
prob = le(prob, V - 1, s1*(p-b), {'V'}, {'b' 's1'});
prob = ge(prob, s1, 0, {'s1'});

%% Initial Lyapunov-guess
% linearization around trim point
A0 = double(subs(A,x,[0; 0])); 
% B0 = double(subs(B,[x;u],[alpha0; q0;eta0])); % check numerical values with paper

% solve Lyapunov equation
P = lyap(A0',eye(2));

prob = setinitial(prob,'V',x'*P*x);

%% Solve
prob = setobjective(prob, -b, {'b'});

% initialize *all* decision variables
prob = setinitial(prob,'s1',1);
prob = setinitial(prob,'s2',(x'*x));
prob = setinitial(prob,'b',1);

% solve by sequential sum-of-squares optimization
iter = bisos.Sequential(prob,'display','step');
% define output message and function
% iter = iter.addmessage('gamma = 1,\t beta = %f\n',{'b'});
% iter = iter.addoutputfcn(@plot_sol,{'V' 'b'},p,x,D);

% use dual representation
iter.options.checkfeas = 'step';
iter.options.sosoptions.form = 'image';
iter.options.sosoptions.scaling = 'off';
iter.options.Niter = 100;
iter.options.sosoptions.solver = 'mosek';

% solve iteration
[sol,info] = run(iter);

disp(sol)

function stop = plot_sol(V,b,p,x,D)
%% plot solution
V = subs(V,x,D*x);
p = subs(p,x,D*x);

figure(2)
clf
pcontour(V, double(1), [-.75 .75 -4 4], 'b-');
hold on
pcontour(p, double(b), [-.75 .75 -4 4], 'r--');

stop = false;
end