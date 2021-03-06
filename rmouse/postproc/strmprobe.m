function strmprobe(ch,intv,plotScheme)
% ** function strmview(ch,intv,plotScheme)
% standalone 'stream viewer' for data streams as generated by rmouse. Needs DS and AP as
% global vars in the workspace
% ch        channels (cell array)
% intv      time interval (s)

global DS AP WP

if nargin<3
  plotScheme=3;
end

labelscale('fontSz',10,'scaleFac',1.0,'lineW',.25,'markSz',4); 
rmouse_ini;
rmouse_apcheck;
rawCh=rmouse_chan;

nCh=length(ch);
% local indices to channels
chInd=[];
for i=1:nCh
  chInd=[chInd strmatch(ch{i},AP.rawChAnNm,'exact')];
end
if isempty(chInd), error('check channel names'); end

% the stream types to be plotted (in case they exist)
strmType={'sansDelta','theta','thetaEnv','gamma','gammaEnv','ripple','rippleEnv'};
nStrms=length(strmType);

if isempty(strfind(DS.dpath,':')), DS.dpath=[WP.rootPath DS.dpath]; end
if isempty(strfind(AP.strmDir,':')), AP.strmDir=[WP.rootPath AP.strmDir]; end

% generate one var for each stream, this is most flexible for all sorts of plots,
% including pllplot overlays
strmTypeExist=zeros(1,nStrms);
for ci=length(chInd):-1:1
  % start by loading abf file, thus obtaining si
  if ci==length(chInd)
    if exist([DS.dpath '\' DS.abfFn '.mat'],'file')
      [rawD,si]=matDload([DS.dpath '\' DS.abfFn '.mat'],'start',intv(1),'stop',intv(2),'channels',ch);
    else
      [rawD,si]=abfload([DS.dpath '\' DS.abfFn '.abf'],'start',intv(1),'stop',intv(2),'channels',ch);        
    end
    if DS.rawSignalInverted
      rawD=-1*rawD;
    end
    intvPts=cont2discrete(intv*1e6,si,'intv',1);
  end
  for stIx=1:length(strmType)
    eval(['fNm=[AP.strmDir ''\'' rawCh(chInd(ci)).' strmType{stIx} 'Fn];']);
    if exist(fNm,'file')
      eval([strmType{stIx} 'D(:,ci)=strmread([AP.strmDir ''\'' rawCh(chInd(ci)).' strmType{stIx} 'Fn],''intv'',intvPts,''verbose'',0);' ]);
      strmTypeExist(stIx)=1;
    end
  end
end

strmType=strmType(logical(strmTypeExist));
nStrms=length(strmType);
clear fNm strmTypeExist stIx 


% -----------------------------------------------------------------------
%                       PREPROCESSING 
% -----------------------------------------------------------------------
% % some filtering
% rawD=hifi(rawD,si,4,'rs',40);
% rawD=bafi(rawD,si,[4 90]);
% rawD=lofi(rawD,si,40);
% thetaEnvD=lofi(thetaEnvD,si,1.0,'rs',30);
% thetaD=rawD; %lofi(rawD,si,12,'rs',40);
% thetaD=bafi(rawD,si,[6 12],'rs',40);
% thetaEnvD=bafi(rawD,si,[4 25],'rs',40);
% thetaEnvD=abs(hilbert(thetaD));
% thetaD=lofi(rawD(1:5:end,:),si*5,4,'rs',30);
% thetaEnvD=hifi(thetaD,si*5,.5,'rs',30);
% deltaD=lofi(deltaD,si,3,'rs',30);
% gammaD=bafi(rawD,si,[40 90],'rs',40);
% gammaD=killhum(gammaD,si,60);
% gammaEnvD=lofi(gammaEnvD,si,12,'rs',50);
% betaD=bafi(rawD,si,[15 30],'rs',40);

% % *** uniform-amplitude theta  
% thetaD=thetaD./thetaEnvD;

% -----------------------------------------------------------------------
%                       RAW DATA 
% -----------------------------------------------------------------------
% % *** detect epileptiform activity/AF
% if 1
%   % normalize traces by difference 10th-90th percentile
%   [n1 n2]=size(rawD);
%   nrm=diff(prctile(rawD,[10 90],1));
%   rawD=rawD./repmat(nrm,n1,1);
% 
%   rawDiff=abs(hilbert(diff(rawD,1,1)));
%   rawD(end,:)=[];
%   
%   rawMn=mean(rawDiff,2)*50;
% 
% else
%   if 1
%     rawDiff=abs(hilbert(diff(rawD,1,1)));
%     rawD(end,:)=[];
%   else
%     rawDiff=abs(hilbert(rawD));
%   end
%   [n1 n2]=size(rawDiff);
%   % normalize diff traces by xth percentile
%   nrm=prctile(rawDiff,90,1);
%   rawDiff=rawDiff./repmat(nrm,n1,1);
%   rawMn=mean(rawDiff,2);
%   % rawStd=std(rawDiff,0,2);
% end
% 
% figure(1)
% if 0
%   scaleCell(1:nCh)={'raw'};
%   scaleCell{end+1}='other';
%   pllplot([rawD rawMn./rawStd],'si',si,'yscale',scaleCell);
% elseif 0
%   scaleCell(1:nCh)={'raw'};
%   scaleCell(end+1)={'other'};
%   pllplot([rawD rawMn],'si',si,'yscale',scaleCell);
% else
%   pllplot([rawD rawMn],'si',si);
%   figure(2)
%   hist(rawMn,0:.05:12);
% end
% return

% 
% % ---- contour plots of streams - nice zebra you've got there!
% % thetaD=thetaD./abs(hilbert(thetaD));
% colormap bone
% figure(1), clf, orient landscape
% subplot(2,1,1)
% [c,cph]=contourf(thetaD',20);
% set(cph,'linestyle','none');
% set(gca,'ydir','rev')
% subplot(2,1,2)
% gammaEnvD=lofi(gammaEnvD,si,20,'rs',30,'pickf',5);
% [c,cph]=contourf(gammaEnvD',20);
% set(cph,'linestyle','none');
% set(gca,'ydir','rev')
% cl=get(gca,'clim');
% set(gca,'clim',[cl(1) cl(2)*.5]);
% return


% % all-points histograms
% fh=figure(1);
% clf, orient landscape
% set(gcf,'position',[9 327 1125 619]);
% labelscale('fontSz',6,'scaleFac',1.0,'lineW',.25,'markSz',4); 
% stix=2;
% switch stix
%   case 1
%     snm='d(raw)/dt (mV/s)';
%     bins=-200:.2:200;
%     sampFac=2;
%     % eliminate everything above low gamma, then diff
%     %rawD=lofi(rawD,si,30);
%     d=diff(rawD,1)/(si/1e6);
%   case 2
%     snm='raw';
%     bins=-2:.02:2;
%     sampFac=2;
%     d=rawD;
%   case 3
%     snm='theta';
%     bins=-2:.02:2;
%     sampFac=10;
%     d=thetaD;
%   case 4
%     snm='gamma';
%     bins=-.8:.005:.8;
%     sampFac=2;
%     d=gammaD;
% end
% for jj=1:nCh
%   subplot(2,8,jj);
%   % exclude all points larger than bin borders because these will skew the
%   % percentiles significantly
%   d(d<bins(1) | d>bins(end))=nan;
%   [n,b]=hist(d(1:sampFac:end,jj),bins);
%   % find & mark percentiles
%   co=cumh(d(1:sampFac:end,jj),.001,'p',[.02 .5 .98]);
%   barh(b,n,1.0,'grouped','k');
%   % set(gca,'ylim',b([1 end]));
%   set(gca,'ylim',[-.5 .5]);
%   xlim=get(gca,'xlim');
%   line(repmat([0; xlim(2)],1,size(co,1)),[co co]','color','r');
%   rexy('xfac',1.2,'yfac',1.1);
% %  ultext(snm);
% end
% print('-djpeg80',['d:\rmouse\ALLPTHIST_BETA3KO_' AP.resFn]);
% 
% return


% -----------------------------------------------------------------------
%                       PHASE PLANE ANALYSIS 
% -----------------------------------------------------------------------

% % *** 2D trajectory of theta ch1 vs theta ch2
% % downsample a bit (~200 Hz)
% thetaD=thetaD(1:3:end,:);
% nPt=length(thetaD);
% 
% % -- do a very simplistic kind of Poincare section
% nf=2;
% figure(1), subplot(2,1,nf)
% % identify transitions neg->pos
% ix=tcd(thetaD(:,1),'idx',.0002);
% % plot, normalizing by stdev of signal
% plot(ix{1}(1:end-1),diff(thetaD(ix{1},2)/std(thetaD(:,2))),'ko-');
% niceyax;
% subpax(gcf)
% 
% figure(2), subplot(2,1,nf)
% hist(diff(thetaD(ix{1},2)/std(thetaD(:,2))),100);
% subpax(gcf)
% return
% 
% figure(1), clf, hold on
% % 50 pts = 250 ms
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',50,'olap',20);
% nInterval=size(intrvls,1);
% for g=1:nInterval
%   plot(thetaD(intrvls(g,1):intrvls(g,2),1),thetaD(intrvls(g,1):intrvls(g,2),2),'o-');
%   axis([-1 1 -.4 .4]);
%   drawnow
%   pause(.05)
% end
% 
% 
% % -- now look at trajectory 1/8 s after peak
% deltaT=ceil(1e6/8/(si*5));
% r=evdeal(thetaD,'idx',{'allpeaks'});
% % peaks of first channel
% npTheta=r.negPeakT{1};
% % discard peaks too close to border
% npTheta(npTheta+deltaT>size(thetaD,1))=[];
% nPeak=numel(npTheta);
% % plot 
% figure(2), clf, hold on
% plot(thetaD(npTheta,1),thetaD(npTheta,2),'gd');
% plot(thetaD(npTheta+deltaT,1),thetaD(npTheta+deltaT,2),'ro');
% 
% return

% % *** 2D plot of beta vs theta: do they have a fixed phase relationship?
% figure(1), clf, hold on
% betaD=bafi(rawD,si,[12 25],'rs',50);
% betaEnvD=abs(hilbert(betaD));
% % uniform-amplitude streams
% thetaD=thetaD./thetaEnvD;
% betaD=betaD./betaEnvD;
% % downsample a bit (~200 Hz)
% thetaD=thetaD(1:5:end,:);
% betaD=betaD(1:5:end,:);
% nPt=length(thetaD);
% % 50 pts = 250 ms
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',50,'olap',20);
% nInterval=size(intrvls,1);
% for g=1:nInterval
%   plot(thetaD(intrvls(g,1):intrvls(g,2),:),betaD(intrvls(g,1):intrvls(g,2),:),'o-');
%   axis([-1.2 1.2 -1.2 1.2]);
%   pause
% end
% 
% return

% hilbert transform-based phase (see Haslinger et al 06)
h=hilbert(thetaD);
subplot(2,1,1)
plot(thetaD);
niceyax;
subplot(2,1,2)
plot(atan(imag(h)./thetaD));
niceyax;


return

% -----------------------------------------------------------------------
%                       CROSSCORRS 
% -----------------------------------------------------------------------
% % *** long-range crosscorrelation
% clf
% nPt=length(thetaD);
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',[30000 31000],'olap',15000);
% nInterval=size(intrvls,1);
% lags=10000;
% CC=zeros(2*lags+1,nInterval);
% for g=1:nInterval
%   [CC(:,g),lll]=xxcorr(detrend(thetaD(intrvls(g,1):intrvls(g,2)),'constant'),lags,'coeff_ub');
% end
% plot(lll,mean(CC,2));
% hold on
% plot(lll,mean(CC,2)+std(CC,0,2),'c');
% return

% % *** crosscorrelation (normal)
% clf
% nPt=length(thetaD);
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',[3000 3100],'olap',500);
% nInterval=size(intrvls,1);
% lags=300;
% CC=zeros(2*lags+1,nInterval);
% for g=1:nInterval
%   if 1
%     % cross
%     [CC(:,g),lll]=xxcorr(detrend(thetaD(intrvls(g,1):intrvls(g,2),2),'constant'),...
%       detrend(thetaD(intrvls(g,1):intrvls(g,2),1),'constant'),lags,'coeff_ub');
%   else
%     [CC(:,g),lll]=xxcorr(detrend(thetaD(intrvls(g,1):intrvls(g,2),1),'constant'),lags,'coeff_ub');
%   end
% end
% figure(78)
% plot(lll,mean(CC,2));
% hold on
% plot(lll,mean(CC,2)+std(CC,0,2),'c');
% niceyax;
% grid on
% return


% % *** crosscorr theta with stream gammaEnvD defined below
% gammaD=bafi(rawD,si,[40 90],'rs',50);
% gammaEnvD=gammaD;
% gammaEnvD=abs(hilbert(gammaD));
% thetaD=bafi(rawD,si,[5 12],'rs',50);
% nPt=length(thetaD);
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',[4000 4100],'olap',1400);
% nInterval=size(intrvls,1);
% lags=500;
% CC=zeros(2*lags+1,nInterval);
% for g=1:nInterval
%   [CC(:,g),lll]=xxcorr(detrend(thetaD(intrvls(g,1):intrvls(g,2)),'constant'),...
%     detrend(gammaEnvD(intrvls(g,1):intrvls(g,2)),'constant'),lags,'coeff_ub');
% end
% figure(2), clf
% subplot(2,1,1)
% plot(lll,mean(CC,2));
% hold on
% plot(lll,mean(CC,2)+std(CC,0,2),'c');
% set(gca,'ytick',-.6:.1:.6);
% grid on
% subplot(2,1,2), hold on
% plot(lll,(CC));
% plot(lll,abs(hilbert((CC))));
% niceyax;
% set(gca,'ytick',-.6:.1:.6);
% 
% return


% % ***** CC of time stamps representing peaks/troughs of theta, beta and gamma
% r=evdeal(thetaD,si,{'allpeaks'});
% ppTheta=r.posPeakT;
% npTheta=r.negPeakT;
% 
% r=evdeal(betaD,si,{'allpeaks'});
% ppBeta=r.posPeakT;
% npBeta=r.negPeakT;
% 
% r=evdeal(gammaD,si,{'allpeaks'});
% ppGamma=r.posPeakT;
% npGamma=r.negPeakT;
% 
% tsl=cat(1,npTheta,npBeta,npGamma);
% tsl2cc(tsl,'lag',250,'binw',2,'chNames',{'theta','beta','gamma'});
% 
% return


% % **** phase relationship theta-theta (between channels)
% clf
% [P,F,nada,phase]=fspecp(rawD(:,1),si,'meth','fft','win',[900 1000],'olap',500,'limFreq',[1 50]);
% [P2,F,nada,phase2]=fspecp(rawD(:,2),si,'meth','fft','win',[900 1000],'olap',500,'limFreq',[1 50]);
% [nada,thFIx]=min(abs(F-9));
% F(thFIx)
% phd1=phase(thFIx,:)-phase2(thFIx,:);
% ph(1)=plot(phd1,'o-');
% ultext(num2str(mean(phd1)));
% % if clear phase relationships exist, the set of phase lags has a single- or double-humped 
% % distribution. In the latter case phases have to be shifted to arrive at meaningful values
% % for averaging
% return

% % ---- attempt to correlate short-term power spec of theta and gamma with
% % short term CC of both
% % --- settings
% colormap bone
% ilen=200;
% olap=50;
% % --- wavelet-based spectrograms
% [P,F,time]=powevol(detrend(rawD(:,1),'constant'),si,'meth','wavelet','ilen',ilen,'olap',olap,'border','skip');
% [P2]=powevol(detrend(gammaEnvD(:,1),'constant'),si,'meth','wavelet','ilen',ilen,'olap',olap,'border','skip');
% % --- determine theta peaks 
% fIx=find(F>4 & F<15);
% r=evdeal(P(fIx,:),'idx',{'minmaxpeak'});
% r2=evdeal(P2(fIx,:),'idx',{'minmaxpeak'});
% % --- short term theta gamma env cc
% % re-convert ms to points 
% intrvls_pts=round(time(1:end-1)/si*1000);
% intrvls_pts(:,2)=round(time(2:end)/si*1000);
% nInt=size(intrvls_pts,1);
% lag=min(100,ilen-20);
% segCC=zeros(2*lag+1,nInt);
% for gg=1:nInt
%   segCC(:,gg)=xcorr(rawD(intrvls_pts(gg,1):intrvls_pts(gg,2),1),...
%     gammaEnvD(intrvls_pts(gg,1):intrvls_pts(gg,2),1),lag,'coeff');
% end
% figure(1), clf
% subplot(3,1,1)
% [c,cph]=contourf(time(1:end),F(fIx),P(fIx,1:end));
% set(cph,'linestyle','none');
% subplot(3,1,2)
% [c,cph]=contourf(time(1:end),F(fIx),P2(fIx,1:end));
% set(cph,'linestyle','none');
% subplot(3,1,3)
% [c,cph]=contourf(1:nInt,-lag:lag,segCC);
% set(cph,'linestyle','none');
% figure(2), clf
% subplot(2,2,1)
% plot(r.maxPeak,r2.maxPeak,'+');
% nicexyax;
% xlabel('theta');
% ylabel('gamma env');
% title('amplitudes')
% subplot(2,2,2)
% plot(F(fIx(r.maxPeakT)),F(fIx(r2.maxPeakT)),'o');
% nicexyax;
% xlabel('theta');
% ylabel('gamma env');
% title('peak frequencies')
% % identify intervals with high CC peaks
% rr=evdeal(segCC,'idx',{'minmaxpeak'});
% [co,ncadh,bins]=cumh(rr.minPeak'*-1,.01,'p',[.5]);
% bigIx=find(rr.minPeak<=co*-1);
% figure(3)
% subplot(2,2,1)
% plot(F(fIx),mean(P(fIx,bigIx),2),'k')
% title('theta, large CC')
% niceyuax
% subplot(2,2,2)
% plot(F(fIx),mean(P2(fIx,bigIx),2),'k')
% title('gammaEnv, large CC')
% niceyuax
% subplot(2,2,3)
% plot(F(fIx),mean(P(fIx,setdiff(1:nInt,bigIx)),2),'k')
% title('theta, small CC')
% niceyuax
% subplot(2,2,4)
% plot(F(fIx),mean(P2(fIx,setdiff(1:nInt,bigIx)),2),'k')
% title('gammaEnv, small CC')
% niceyuax

% -----------------------------------------------------------------------
%                       THINGS SPECTRAL  
% -----------------------------------------------------------------------

% % ***** coherence theta-gammaEnv
% win=4096;
% nfft=win;
% noverlap=3000;
% limFreq=20;
% coh=[];
% for g=1:nCh
%   [cxy,f] = mscohere(rawD(:,2),gammaEnvD(:,g),win,noverlap,nfft,1e6/si);
%   coh=[coh cxy];
% end
% coh=coh(f<=limFreq,:);
% f=f(f<=limFreq,:);
% figure(1), hold on % clf
% % pllplot(coh);
% plot(f,coh-repmat(0:nCh-1,size(coh,1),1));
% niceyax;
% grid on
% % axis([0 16 0 1]);
% return
% 

% **** compute instantaneous power on basis of filtering and computing envelope
% fifi=4:1.0:22;
% nFifi=length(fifi);
% % 1st chan
% rd=rawD(:,1);
% eD=repmat(rd,1,nFifi-1);
% for g=1:nFifi-1
%   eD(:,g)=abs(hilbert(bafi(rd,si,fifi([g g+1]),'rs',50)));
% end
% eD=eD(1:10:end,:);
% figure(22)
% contourf(1:size(eD,1),fifi(1:end-1)+diff(fifi(1:2))/2,eD');
%  
% % 2nd chan
% rd=rawD(:,2);
% eD=repmat(rd,1,nFifi-1);
% for g=1:nFifi-1
%   eD(:,g)=abs(hilbert(bafi(rd,si,fifi([g g+1]),'rs',50)));
% end
% eD=eD(1:10:end,:);
% figure(23)
% contourf(1:size(eD,1),fifi(1:end-1)+diff(fifi(1:2))/2,eD');
% 
% % return


% % **** spectrogram
% spectrogram(rawD,512,450,512,1e6/si,'yaxis');
% set(gca,'ylim',[100 200])
% return

% *** power spectrum of 'normal' segments
[P,F]=fspecp(rawD,si,'win',[4000 4100],'olap',1000,'limFreq',[0 175]);
figure(10); 
plot(F,P,'b');
set(gca,'yscale','log');
niceyax
return

% % *** power spectrum of short segments
% [P,F]=fspecp(rawD,si,'win',[1900 2000],'olap',1000,'limFreq',[50 200]);
% figure(11); 
% subplot(2,1,1)
% plot(F,P,'b');
% niceyax;
% subplot(2,1,2)
% plot(F,P,'b');
% set(gca,'yscale','log');
% niceyax
% return

% % *** power spectrum gammaEnv
% figure(2)
% for i=1:nCh
%   [P,F]=fspecp(gammaEnvD(:,i),si,'win',[3900 4000],'olap',2000,'limFreq',[1 30]);
%   subplot(nCh,1,i)
%   plot(F,P,'b');
%   niceyax;
%   % set(gca,'yscale','log');
% end
% subpax(gcf);
% 
% return

% -----------------------------------------------------------------------
%                       OTHER 
% -----------------------------------------------------------------------

% % *** current source density
% cusode=cursd(thetaD);
% clf
% nPt=length(thetaD);
% [intrvls,intrvls_pts]=mkintrvls([1 nPt],'ilen',1000,'olap',900);
% nInterval=size(intrvls,1);
% for g=1:nInterval
%   subplot(1,2,1),
%   pllplot(thetaD(intrvls(g,1):intrvls(g,2),:),'si',si);
%   subplot(1,2,2),
%   pllplot(cusode(intrvls(g,1):intrvls(g,2),:),'si',si);
%   pause
% end
% return

% % --- coefficient of variation of theta envelope
% cv=std(thetaEnvD,0,1)./mean(thetaEnvD,1);
% figure(11), hold on
% plot(cv,'mo-')
% title('cv');
% return

% ---- see theta peaks as found by evdeal (1 channel)
% % the raw 
% clf, hold on
% plot(thetaD,'r');
% thetaD=lofi(thetaD,si,17,'rs',30);
% r=evdeal(thetaD,'idx',{'allpeaks'});
% plot(thetaD);
% hold on;
% plot(r.negPeakT{1},r.negPeak{1},'ro');
% return

% % --- gamma freq (# of ascending zerol line crossings)
% bg=sum(diff(gammaD>0,1,1)==1,1)/diff(intv)
% return



pscheme=3;
switch pscheme
  case 0
    % all streams of each channel overlaid
    figure(1), clf, hold on, orient landscape
    % raw data first
    [yl,dy]=pllplot(rawD,'si',si,'noscb',1,'noplot',0);
    % streams next
    pllplot(thetaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);
    pllplot(gammaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);
%    pllplot(gammaD+thetaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);
    % pllplot(ripple,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',0);
    % different colors for different streams
    c=get(gca,'children');
    % first plot==last child. So, leaving raw data black..
    set(c(end-2*nCh+1:end-1*nCh),'color','b');
    set(c(end-3*nCh+1:end-2*nCh),'color','r');    
%     set(c(end-4*nCh+1:end-3*nCh),'color','c');        
%     set(c(end-5*nCh+1:end-4*nCh),'color','m');        
%     set(c(end-6*nCh+1:end-5*nCh),'color','g');            
  case 1
    % all streams of each channel overlaid
    figure(1), clf, hold on, orient landscape
    % raw data first
    [yl,dy]=pllplot(rawD,'si',si,'noscb',1);
    % streams next
    pllplot(thetaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);
    pllplot(thetaEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);  
    pllplot(gammaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);
    pllplot(gammaEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);    
    pllplot(deltaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',1);    
    % pllplot(ripple,'si',si,'spacing','fixed','dy',dy,'ylim',yl,'noscb',0);
    % different colors for different streams
    c=get(gca,'children');
    % first plot==last child. So, leaving raw data black..
    set(c(end-2*nCh+1:end-1*nCh),'color','b');
    set(c(end-3*nCh+1:end-2*nCh),'color','r');    
    set(c(end-4*nCh+1:end-3*nCh),'color','c');        
    set(c(end-5*nCh+1:end-4*nCh),'color','m');        
    set(c(end-6*nCh+1:end-5*nCh),'color','g');            
  case 2
    % each stream type in a separate figure window
    figure(1), clf, orient landscape
    pllplot(rawD,'si',si);
    title('raw','fontsize',16,'fontweight','bold');    
    for i=1:nStrms
      figure(i+1), clf, orient landscape
      eval(['pllplot(' strmType{i} 'D,''si'',si);']);
      title(strmType{i},'fontsize',16,'fontweight','bold');
    end
  case 3
    figCount=1;
    % streams with corresponding envelope overlaid; raw with delta overlaid
    figure(figCount), clf, hold on, orient landscape
    [yl,dy]=pllplot(rawD,'si',si,'noscb',1);
    pllplot(sansDeltaD,'si',si,'spacing','fixed','dy',dy,'ylim',yl);  
    % different color for raw
    c=get(gca,'children');
    % first plot==last child. So, leaving sansDelta black..
    set(c(end-1*nCh+1:end-0*nCh),'color',[.2 .2 .9]); %[.5 .8 .5] [.1 .6 .05]
    title('blue: 1-300 Hz; black: 4-300 Hz','fontsize',16,'fontweight','bold');

    % thetaD
    figCount=figCount+1;
    figure(figCount), clf, hold on, orient landscape   
    [yl,dy]=pllplot(thetaD,'si',si,'noscb',1);
    pllplot(thetaEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl);  
    % different color for stream proper
    c=get(gca,'children');
    % first plot==last child. So, leaving enevelope black..
    set(c(end-1*nCh+1:end-0*nCh),'color',[.7 .3 1]);
    title('{\theta}','fontsize',16,'fontweight','bold');

    % theta hi (if it exists)
    if any(ismember(strmType,'thetaHi'))
      figCount=figCount+1;
      figure(figCount), clf, hold on, orient landscape
      [yl,dy]=pllplot(thetaHiD,'si',si,'noscb',1);
      pllplot(thetaHiEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl);
      % different color for stream proper
      c=get(gca,'children');
      % first plot==last child. So, leaving enevelope black..
      set(c(end-1*nCh+1:end-0*nCh),'color',[.7 .3 1]);
      title('{\theta} hi','fontsize',16,'fontweight','bold');
    end

    % gamma
    figCount=figCount+1;
    figure(figCount), clf, hold on, orient landscape   
    [yl,dy]=pllplot(gammaD,'si',si,'noscb',1);
    pllplot(gammaEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl);    
    % different color for stream proper
    c=get(gca,'children');
    % first plot==last child. So, leaving enevelope black..
    set(c(end-1*nCh+1:end-0*nCh),'color',[.7 .3 1]);
    title('{\gamma}','fontsize',16,'fontweight','bold');

    % ripple (if it exists)
    if any(ismember(strmType,'ripple'))
      figCount=figCount+1;
      figure(figCount), clf, hold on, orient landscape
      [yl,dy]=pllplot(rippleD,'si',si,'noscb',1);
      if any(ismember(strmType,'rippleEnv'))
        pllplot(rippleEnvD,'si',si,'spacing','fixed','dy',dy,'ylim',yl);
        % different color for stream proper
        c=get(gca,'children');
        % first plot==last child. So, leaving enevelope black..
        set(c(end-1*nCh+1:end-0*nCh),'color',[.7 .3 1]);
      end
      title('ripple','fontsize',16,'fontweight','bold');
    end
end



