tic
para = ParaGen_Estimator();
est = Est_EKF(para.ekf);
[acPara, buffPred, buffPredCova, buffResid, buffResidCova] = est.calibrate(totalTT);
%%
p.b = buffPred(:,4);
p.Cxx = buffPred(:,5);
p.Cyy = buffPred(:,6);
p.Czz = buffPred(:,7);

pCov.b = buffPredCova(:,4,4);
pCov.Cxx = buffPredCova(:,5,5);
pCov.Cyy = buffPredCova(:,6,6);
pCov.Czz = buffPredCova(:,7,7);
%%
r.wn = buffResid(:,1);
wn_bias = mean(r.wn)
wn_std = std(r.wn)
r.we = buffResid(:,2);
r.wd = buffResid(:,3);

rCov.wn = buffResidCova(:,1,1);
rCov.we = buffResidCova(:,2,2);
rCov.wd = buffResidCova(:,3,3);


%%
figure(1)
subplot(2,2,1); plot(p.b); title("b")
subplot(2,2,2); plot(p.Cxx); title("Cxx")
subplot(2,2,3); plot(p.Cyy); title("Cyy")
subplot(2,2,4); plot(p.Czz); title("Czz")

figure(2)
subplot(2,2,1); plot(pCov.b); title("b")
subplot(2,2,2); plot(pCov.Cxx); title("Cxx")
subplot(2,2,3); plot(pCov.Cyy); title("Cyy")
subplot(2,2,4); plot(pCov.Czz); title("Czz")

figure(3)
subplot(2,2,1); plot(r.wn); title("wn")
subplot(2,2,2); plot(r.we); title("we")
subplot(2,2,3); plot(r.wd); title("wd")

% 
% figure(4)
% subplot(2,2,1); plot(rCov.wn); title("wn")
% subplot(2,2,2); plot(rCov.we); title("we")
% subplot(2,2,3); plot(rCov.wd); title("wd")


toc