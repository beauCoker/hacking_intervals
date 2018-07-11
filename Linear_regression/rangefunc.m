%%%%% This function finds betastar

function [betamin,betamax]=rangefunc(x,y,xnew,theta)
invmat=inv(transpose(x)*x);
Upsilon= invmat*(transpose(xnew))
betaLS= invmat*(transpose(x)*y)

% Define a, b, c for quadratic formula
a=sum((x*Upsilon).^2);
b=-2*sum((transpose(y-x*betaLS))*(x*Upsilon));
c=sum((y-x*betaLS).^2)-theta

% Here's the solution
mutildeplus=( -b + sqrt(b^2-(4*a*c)))/(2*a)
mutildeminus= (-b - sqrt(b^2-(4*a*c)))/(2*a);
betamax=Upsilon*mutildeplus +betaLS;
betamin=Upsilon*mutildeminus+betaLS;

% print out the range
xnew*betamax
xnew*betamin

%%% sanity check
V=transpose(x*Upsilon)*(y-x*betaLS);
mupl = (-V+sqrt(V^2 - sum( (x*Upsilon).^2 ) ...
   *(sum((y-x*betaLS).^2)-theta)))/(sum((x*Upsilon).^2))
% this should equal mutildeplus
end