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
[prob,s2] = sosdecvar(prob,'s2',monomials(x,1:2));

% level sets
[prob,g] = decvar(prob,'g');
[prob,b] = decvar(prob,'b');

%% Constraints
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});

% Stable level set
prob = le(prob, gradV*f + l, s2*(V-g), {'dV'}, {'V' 'g' 's2'});
prob = ge(prob, s2, 0, {'s2'});
prob = ge(prob, V, l, {'V'});

% Inscribing ellipsoid
prob = le(prob, V - g, s1*(p-b), {'V' 'g'}, {'b' 's1'});
prob = ge(prob, s1, 0, {'s1'});

%% Initial Lyapunov-guess
% linearization around origin
J0 = double(subs(J,x,zeros(2,1)));

% solve Lyapunov equation
P = lyap(J0',eye(2));

prob = setinitial(prob,'V',x'*P*x);

% set trivial inscribing shape
prob = setinitial(prob,'b',0);

%% Solve
prob = setobjective(prob, -b, {'b'});

% define iteration explicitly
iter = bisos.Iteration(prob, 'display','debug');
iter = iter.addconvex({'V'});
iter = iter.addbisect({'s1'},-b,{'b'});
iter = iter.addbisect({'s2'},-g,{'g'},1:3);

% plot iteration scheme
figure(1)
subplot(1,2,1)
plot(graph(iter),'Layout','layered')

subplot(1,2,2)
plot(route(iter),'Layout','layered')

% solve iteration
sol = run(iter);
