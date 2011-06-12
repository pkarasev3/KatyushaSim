function [xL1 primal dual xL2] = solveBasisPursuit_L1( A, b )
% minimize ||x||_1 subject to Ax=b
% note: only makes sense for A "short and fat", i.e. underdetermined
% input: A,b 
% output: xL1 solution, primal & dual vars (internal / for clarification)
% xL2 solution for comparison to xL1

if( size(A,1) >= size(A,2) )
  warning('system does not seem underdetermined... might crash or be bogus answer!'); %#ok<WNTAG>
end

% suggested in: 
% OPTIMIZATION TECHNIQUES FOR SOLVING
% BASIS PURSUIT PROBLEMS
% By
% Kristen Michelle Cheman
% A Thesis Submitted to the Graduate
% Faculty of North Carolina State University
% in Partial Fulﬁllment of the
% Requirements for the Degree of
% MASTER OF APPLIED MATHEMATICS

% x :- desired sparse solution

% support :- support set for vector x

% lsupport :- cardinality of the support set

[m,n] = size(A);

Amatrix = [A' 2*eye(n)];

bvector = ones(n,1);

cvector = [-b; zeros(n,1)];

lb = [-inf*ones(m,1); zeros(n,1)];

ub = [inf*ones(m,1); ones(n,1)];

% track the time required to solve the dual problem

%profile on

[primal,obj,exitflag,output,dual] = linprog(cvector,[],[],Amatrix,bvector,lb,ub);

%profile viewer

% x is the dual variable corresponding to the equality constraints in dual problem

xL1 = dual.eqlin;

% Let us compute the support set of x

support = find(abs(xL1)/max([1 normest(A) norm(b)]) > 1e-8);

% Compute the cardinality of the support set

lsupport = length(support);

xL2 = A' *( ( A * A' ) \ b );
