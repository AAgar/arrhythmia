% remove 14th row
% remove the patients with missing data
for i=1:452
   temp = sum(isnan(table2array(arr(i,:))));
   if temp>=1
       rem = i;
       toRem = [toRem; rem];
   end
end
% remove condition 16
arr(find(table2array(arr(:,end))==16),:) = []; %#ok<FNDSB>
% arr(toRem,:) = [];
t = table2array(arr(:,end));
t2=(t>1)+1;



tempTree = templateTree('NumPredictorsToSample','all',...
    'PredictorSelection','interaction-curvature','Surrogate','on');
rng(1); % For reproducibility
Mdl = fitcensemble(arr(:,1:end-1),t,'OptimizeHyperparameters','all',...
    'HyperparameterOptimizationOptions',struct('Verbose',1,'AcquisitionFunctionName','expected-improvement-plus', 'Optimizer', 'bayesopt', 'MaxObjectiveEvaluations', 30));

cvMdl = crossval(Mdl); 
outMulti = kfoldPredict(cvMdl);
length(find(outMulti==tMulti))/length(tMulti)
length(find(out2==t2))/length(t2)

% R2 = corr(Mdl.Y,out)^2;

% [impGain,predAssociation] = predictorImportance(Mdl);
% 
% figure;
% plot(1:numel(Mdl.PredictorNames),[impOOB' impGain']);
% title('Predictor Importance Estimation Comparison')
% xlabel('Predictor variable');
% ylabel('Importance');
% h = gca;
% h.XTickLabel = xNoSP.Properties.VariableNames(1:end-1);
% h.XTickLabelRotation = 45;
% h.TickLabelInterpreter = 'none';
% legend('OOB permuted','MSE improvement')
% grid on
% 
% figure;
% imagesc(predAssociation);
% title('Predictor Association Estimates');
% colorbar;
% h = gca;
% h.XTickLabel = xNoSP.Properties.VariableNames(1:end-1);
% h.XTickLabelRotation = 45;
% h.TickLabelInterpreter = 'none';
% h.YTickLabel = xNoSP.Properties.VariableNames(1:end-1);

% % accuracy for disease +
% length(find(out~=1 & t==out)) / length(find(out~=1))
% % accuracy for disease -
% length(find(out==1 & t==1)) / length(find(out==1))

perClassAcc2 = [];
classes = unique(t2);
for i = 1:length(classes)
    class = classes(i);
    numCorr = length(find(out2==class & t2==class));
    numWrong = length(find(out2==class & t2~=class));
    acc = numCorr/(numCorr+numWrong);
    perClassAcc2 = [perClassAcc2; class acc numCorr (numCorr+numWrong) length(find(t==class))];
end

perClassAccMulti = [];
classes = unique(tMulti);
for i = 1:length(classes)
    class = classes(i);
    numCorr = length(find(outMulti==class & tMulti==class));
    numWrong = length(find(outMulti==class & tMulti~=class));
    acc = numCorr/(numCorr+numWrong);
    perClassAccMulti = [perClassAccMulti; class acc numCorr (numCorr+numWrong) length(find(t==class))];
end

cd C:\Users\User1\Documents\GitHub\arrhythmia
[X1,Y1,T1,AUC1,OPTROCPT1] = perfcurve(tMulti,outMulti,1);
figure,
plot(Y1,X1);
[X2,Y2,T2,AUC2,OPTROCPT2] = perfcurve(t2,out2,2);
hold on, plot(X2,Y2);
hold on, plot(0:.1:1, 0:.1:1,'--k','HandleVisibility','off');
% legend(['ROC (AUC: ' num2str(AUC1) ').' char(10) ''], 'location', 'southeast'); %#ok<CHARTEN>
legend(['11-Class ROC (AUC: ' num2str(1-AUC1) ').'], ['2-Class ROC   (AUC: ' num2str(AUC2) ').'], 'location', 'southeast'); 
ylabel('True Positive Rate (Sensitivity')
xlabel('False Positive Rate (1-Specificity)')
set(gca,'box','off')
title('Receiver Operating Characteristic (ROC)');
saveas(gcf, 'ROCboth.png')
% tp = length(find(out~=1 & t==out));
% fn = length(find(out==1 & t~=1));
% totalSP = length(find(t~=1));
% sensitivity = tp/(tp+fn)
% sensitivity2 = tp/(totalSP)

CP2 = classperf(t2, out2, 'Positive', [2], 'Negative', [1]); %#ok<*NBRAK>
% pred=kfoldPredict(RUSBoosted);
% acc = length(find(pred==t2))/length(t2);
% [X2,Y2,T2,AUC2,OPTROCPT2] = perfcurve(t2,pred,2);
% CP2 = classperf(pred, out2, 'Positive', [2], 'Negative', [1]); %#ok<*NBRAK>
sens = CP2.Sensitivity;
spec = CP2.Specificity;
ppv = CP2.PositivePredictiveValue;
npv = CP2.NegativePredictiveValue;
output = [acc AUC2 sens spec ppv npv]


CPMulti = classperf(tMulti, outMulti, 'Positive', [2:10, 14], 'Negative', [1]); %#ok<*NBRAK>
CPMulti.Sensitivity
CPMulti.Specificity
CPMulti.PositivePredictiveValue
CPMulti.NegativePredictiveValue

length(find(outMulti==tMulti))/length(tMulti)
length(find(out2==t2))/length(t2)

% tn = length(find(out==1 & t==1));
% fp = length(find(out~=1 & t==1));
% specificity = tn/(tn+fp)
