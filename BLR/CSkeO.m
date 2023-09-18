function [DAG] = CSkeO(data,G_skeleton,ns)

% build skeleton 
%skeleton=new_rule(skeleton,SepSet,PC,p);
% cpm = tril(sparse(skeleton));
sample = data;
varNValues =ns;
skeleton = G_skeleton;

% create candidate parent matrix
skeleton=sparse(skeleton);
cpm = tril(sign(skeleton + skeleton'));

% create local scorer
LocalScorer = bdeulocalscorer(sample, varNValues);

% create hill climber
HillClimber = hillclimber(LocalScorer, 'CandidateParentMatrix', cpm);

% Finally, we learn the structure of the network.
% learn structure
DAG = HillClimber.learnstructure();


