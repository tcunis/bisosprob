% Region of attraction estimation for the Van der Pol oscillator.
% Demo to test out addsetinclusion functionality

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
[prob,V] = polydecvar(prob,'V',monomials(x,1:4));

% SOS multipliers
%[prob,s1] = sosdecvar(prob,'s1',monomials(x,0));
%[prob,s2] = sosdecvar(prob,'s2',monomials(x,1:2));

% level sets
[prob,g] = decvar(prob,'g');
[prob,b] = decvar(prob,'b');

%% Constraints
[prob,gradV] = substitute(prob,'dV',@(p) sosf.jacob(p,x),{'V'});

% Stable level set
[prob, s1] = addsetinclusion(prob, (V-g), gradV*f + l, {'V' 'g'}, {'dV'});
prob = ge(prob, V, l, {'V'});

% Inscribing ellipsoid
[prob, s2] = addsetinclusion(prob, (p-b), V - g, {'b'}, {'V' 'g'});


%% Initial Lyapunov-guess
% linearization around origin
J0 = double(subs(J,x,zeros(2,1)));

% solve Lyapunov equation
P = lyap(J0',eye(2));

prob = setinitial(prob,'V',x'*P*x);

%% Solve
prob = setobjective(prob, -b, {'b'});

% define iteration explicitly
iter = bisos.Iteration(prob, 'display','step');
iter = iter.sosupdate(s1,s2);
iter = iter.addconvex({'V'});
iter = iter.addbisect({'s2'},-b,{'b'});
iter = iter.addbisect({'s1'},-g,{'g'},{'s2'});
iter = iter.addmessage('gamma = %f,\t beta = %f\n',{'g' 'b'});
iter = iter.addoutputfcn(@plot_sol,{'V' 'g' 'b'},p);

% plot iteration scheme
figure(1)
subplot(1,2,1)
plot(graph(iter),'Layout','layered')

subplot(1,2,2)
plot(route(iter),'Layout','layered')

drawnow

% solve iteration
[sol,info] = run(iter);

disp(sol)

function stop = plot_sol(V,g,b,p)
%% plot solution
figure(2)
clf
pcontour(V, double(g), [-2 2 -2 2], 'b-');
hold on
pcontour(p, double(b), [-2 2 -2 2], 'r--');

stop = false;
end