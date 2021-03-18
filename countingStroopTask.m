% %Counting Stroop Task
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
initials = input('Please enter your initials: ', 's');
outputFile = ['stroop_data_' initials '.mat'];

order_of_conditions = [ones(1,12) zeros(1,12)]; 
R = randperm(24);
order_of_conditions = order_of_conditions(R); %creates vector of 1's and 0's in random order for congruent/non-congruent order

conVect = [4*ones(1,3) 5*ones(1,3) 6*ones(1,3) 7*ones(1,3)];
T = randperm(12);
conVect = conVect(T); %creates vector of #'s 4-7 (3 each) used for congruent #'s and the *quantity* of non-congruent #'s

nonVect = [4*ones(1,3) 5*ones(1,3) 6*ones(1,3) 7*ones(1,3)];
T2 = randperm(12);
nonVect = nonVect(T2); %creates vector of #'s 4-7 (3 each) used for non-congruent #'s (not quantity)
                       %(non-congruent # generation uses 2 vectors since
                       %there needs to be a difference between the # shown
                       %and the quantity of the # shown, whereas congruent
                       %# generation only uses 1 vector)

while ~isempty(find(conVect == nonVect)) %makes sure there's no # overlap between the congruent #'s and non-congruent #'s
    T2 = randperm(12);                   %(e.g. makes sure the non-congruent #'s are indeed non-congruent/different from congruent # vector)
    nonVect = nonVect(T2);
end

figure(1); set(gcf,'color','w'); axis off equal; axis([-3 3 -3 3]);
text(-3,2.5,'Welcome to the Counting Stroop Task!','FontSize',14);
text(-2.25,1,'In each trial, different numbers will appear.');
text(-2.6,0.5,'Respond with the quantity of numbers displayed.');
text(-2,0,'(e.g. 44444 --> 5 numbers displayed.)');
text(-2.8,-0.5,'Use the number keys 4 through 7 for your responses.');
text(-3.1,-1,'Make your responses as quickly and accurately as you can.');
text(-1.5,-3,'Press Enter to continue...','FontSize',12);

input(' ');

trialMatrix = zeros(24,5); %initialize matrix where data will be stored
columnNames = {'trial_num' 'condition' 'quantity' 'response' 'rt'}; %column names to keep track of what ea. column stands for

conCount = 1; %keeps track of the index for each congruent/non-congruent vector
nonCount = 1;

for i = 1:24 %loops through # of trials (24 total)
    cla;
    if order_of_conditions(i) == 1 %1 = congruent
        text(0,0.5,sprintf('%d',conVect(conCount)*ones(1,conVect(conCount))),'FontSize',20,'HorizontalAlignment','center','VerticalAlignment','middle'); %prints #'s to figure
        quant = conVect(conCount); %stores actual quantity(aka. correct answer)
        conCount = conCount + 1; %increments index
    else %0 = non-congruent
        text(0,0.5,sprintf('%d',nonVect(nonCount)*ones(1,conVect(nonCount))),'FontSize',20,'HorizontalAlignment','center','VerticalAlignment','middle');
        quant = conVect(nonCount);
        nonCount = nonCount + 1;
    end
    
    tic;
    
    validKey = 0;
    while validKey == 0 %loops until participant enters valid keyboard press (4-7)
       [x,y,b] = ginput(1);
       if b == 52  %4
           resp = 4;
           validKey = 1;
       elseif b == 53 %5
           resp = 5;
           validKey = 1;
       elseif b == 54 %6
           resp = 6;
           validKey = 1;
       elseif b == 55 %7
           resp = 7;
           validKey = 1;
       end
    end
    
    rt = toc;
    
    trialMatrix(i,1) = i;
    trialMatrix(i,2) = order_of_conditions(i); % (1 = congruent, 0 = non congruent)
    trialMatrix(i,3) = quant; % 4-7
    trialMatrix(i,4) = resp; %4-7
    trialMatrix(i,5) = rt;
    
    save(outputFile, 'trialMatrix', 'columnNames');
    
    pause(0.5);
end

cla;
text(-2.2,0.5,'Thank you for participating!','FontSize',16);
pause(2);
close(1);


%%

%Analysis Section

%This script analyzes Counting Stroop task data with congruent and
%noncongruent responses
%
%The goal is to find:
% - proportion of responses correct (congruent)
% - proportion of responses incorrect (noncongruent)
% - mean reaction time for congruent number trials
% - mean reaction time for noncongruent number trials
% - correlating congruent vs noncongruent groups
% - correlating '4' responses to '7' responses
% - then plot in subplot (x axis length of stimulus, y axis reaction time)

%load 4 participant's data
data_list = {'stroop_data_sk.mat'
    'stroop_data_cy.mat'
    'stroop_data_BS.mat'
    'stroop_data_LS.mat'};

nsubj = length(data_list);

all_performance_con = [];
all_performance_non = [];
all_rt_con = [];
all_rt_non = [];
four_rt = [];
seven_rt = [];


%columnNames = {'trial_num' 'condition' 'quantity' 'response' 'rt'};

for i = 1:nsubj
    
    %4a. first load the data set
%      %this defines trial_matrix and column_names
    load(data_list{i});
    
    %4b. let's find the trials associated with congruent and noncongruent
    %trials
    con_trials = find(trialMatrix(:,2)==1);
    non_trials = find(trialMatrix(:,2)==0);
    
    %4c. let's calculate performance (proportion correct) for congruent and
    %noncongruent using the find command
    correct_con_trials = find(trialMatrix(:,2)==1 & trialMatrix(:,4)==trialMatrix(:,3));
    correct_non_trials = find(trialMatrix(:,2)==0 & trialMatrix(:,4)==trialMatrix(:,3));
    
    performance_con = length(correct_con_trials)/length(con_trials);
    performance_non = length(correct_non_trials)/length(non_trials);
    
    %4d. now let's calculate mean reaction times for *correct* congruent
    %and noncongruent trials
    rt_con = mean(trialMatrix(correct_con_trials,5));
    rt_non = mean(trialMatrix(correct_non_trials,5));
    
    %Determine variables for '4' responses and '7' responses and overall
    %mean reaction time
    four_response = find(trialMatrix(:,3)==4);
    seven_response = find(trialMatrix(:,3)==7);
    four_rt(i) = trialMatrix(four_response(i),5);
    seven_rt(i) = trialMatrix(seven_response(i),5);
    
  % four_seven_responses = find(trialMatrix(:,3)==4 & trialMatrix(:,3)==7); 
   % response_four_correct = find(trialMatrix(:,3)==4 & trialMatrix(:,4)==4);
    
    
%     
    all_performance_con(i) = performance_con;
    all_performance_non(i) = performance_non;
    all_rt_con(i) = rt_con;
    all_rt_non(i) = rt_non;

end



%ttest2 to find whether significant difference in congruent vs noncongruent
%trials
[H, P, CI, STATS] = ttest2(all_performance_con,all_performance_non);
%H = 0 -- fail to reject the null hypothesis 
%P = 0.3153 --- not significant, therefore people guessed/answered correct
%or incorrect same amount of times basically 
%CI = -0.2695 0.1028
%STATS = tstat = -1.0954
%df = 6
%sd = 0.1076


%ttest2 to see if number quantity impacted response times
[H, P, CI, STATS] =  ttest2(four_rt,seven_rt); %we want to compare 4 vs 7 reaction times
%H = 0 -- fail to reject the null hypothesis
%P = .5478 large p therefore not significant
%CI = -0.8146 0.4782
%STATS = df:6 sd: 0.3736



%%4e. finally let's display these results in a figure with two side-by-side
%subplots showing bar graphs, one for proportion correct (congruent vs. noncongruent) 
%and one for rt (congruent vs. noncongruent)
figure(3)

subplot(1,2,1)
y = [mean(all_performance_con) mean(all_performance_non)];
bar(y)
axis([0 3 0 2])
xticks([1 3])
xticklabels({'Congruent','Noncongruent'})
ylabel('Proportion correct');
title('Performance across participants')

subplot(1,2,2)
y = [mean(all_rt_con) mean(all_rt_con)];
bar(y)
axis([0 3 0 1.8])
xticks([1 3])
xticklabels({'Congruent','Noncongruent'})
ylabel('Average reaction time (sec)');
title('Reaction time across participants')

figure(4)
subplot(1,2,1)
y = [mean(four_rt) mean(seven_rt)];
bar(y)   
xticks([1 3])
xticklabels({'4 Responses','7 Responses'})
ylabel('Average RT')
title('4 vs 7 Response RT')

subplot(1,2,2)
y = [mean(four_response) mean(seven_response)];
bar(y)
xticks([1 3])
xticklabels({'All 4 Responses','All 7 Responses'})
ylabel('Correct Responses')
title('All 4 vs 7 Responses')