clear all
clc

% The type of classifier to use 
classifier_types = {'random_forest', 'svm', 'nn', '3nn', '5nn'};
n_types = length(classifier_types);

classifier_options = cell(3,1);
for t = 1:n_types
	type = classifier_types{t};
	switch type
		case 'svm'
% 			classifier_options{t} = '-t 1 -d 3 -gamma 100';
			classifier_options{t} = '-t 0';
		case 'random_forest'
			classifier_options{t}.use_weighted_trees = false;
		otherwise  
			classifier_options{t} = '';
	end
end

% The data set to use
csvfile = 'training/training.csv';

%% Set up data

% Read data set
[path name ext] = fileparts(csvfile);
SET             = get_dataset(csvfile);
% Get all features
[F F_STR]  = get_all_features(SET);


%% Split data set
train_to_test_ratio = 1/2;

TEST = [];
TRAIN = [];

for classid = 1:max(SET.CLASS(:))
     
    examples = find(SET.CLASS == classid);
    %examples = examples(randperm(length(examples)));
    
    train_class = examples(1:2:end);
    test_class = setdiff(examples,train_class); 
    
    TRAIN = [TRAIN train_class];
    TEST = [TEST test_class];
end


 

fprintf('\n');
fprintf('Training size : %d\n',numel(TRAIN));
fprintf('Test size     : %d\n',numel(TEST));
fprintf('\n');


%% Create classifiers
classifier = cell(n_types, 1);
C_train = SET.CLASS(TRAIN)';
for t = 1:n_types
	type = classifier_types{t};
	options = classifier_options{t};
	
	tic
	classifier{t} = Classifier(type, F(TRAIN,:), C_train, options);
	fprintf('Training time for %s: %.2f seconds.\n', type, toc);
end

%% Evaluate classifiers
C_test = SET.CLASS(TEST)';
for t = 1:n_types
	type = classifier_types{t};

	tic
	C = classifier{t}.classify(F(TEST,:));
	time_taken = toc;
	ncorrect = sum(C == C_test);
	result = ncorrect / length(TEST);
	fprintf('Result for %s: %.2f%%  (%.2f s).\n', type, 100*result, time_taken);
end
