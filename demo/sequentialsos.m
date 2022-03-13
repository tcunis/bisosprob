% Region of attraction estimation for the Van der Pol oscillator.

import sosfactory.sosopt.*

sosf = SosoptFactory;

x = polyvar(sosf,'x',2,1);

f = [x(2); -(1-x(1)^2)*x(2) - x(1)];

% Jacobian matrix
J = sosf.jacob(f,x);

% polynomial shape
p = x'*x;

% epsilon polynomial
l = x'*x*1e-6;

prob = bisosprob(sosf,x);

%% Decision variables
% Lyapunov candidate
[prob,V] = polydecvar(prob,'V',[x(1)^2; x(1)*x(2); x(2)^2]);

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
% linearization around origin
J0 = double(subs(J,x,zeros(2,1)));

% solve Lyapunov equation
P = lyap(J0',eye(2));

prob = setinitial(prob,'V',x'*P*x);

%% Solve
prob = setobjective(prob, -b, {'b'});

% initialize *all* decision variables
prob = setinitial(prob,'s1',1);
prob = setinitial(prob,'s2',1);
prob = setinitial(prob,'b',1);

% solve by sequential sum-of-squares optimization
iter = bisos.Sequential(prob, 'display','result');
% define output message and function
iter = iter.addmessage('gamma = 1,\t beta = %f\n',{'b'});
iter = iter.addoutputfcn(@plot_sol,{'V' 'b'},p);

% use dual representation
iter.options.sosoptions.form = 'kernel';
iter.options.Niter = 100;

% solve iteration
sol = run(iter);

disp(sol)

function stop = plot_sol(V,b,p)
%% plot solution
figure(2)
clf
pcontour(V, double(1), [-2 2 -2 2], 'b-');
hold on
pcontour(p, double(b), [-2 2 -2 2], 'r--');

stop = false;
end