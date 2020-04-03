% ------- plots of time course:
% ------ peaks of theta
% - 20 subplots per page, ca. 4 s per line
% to do:

labelscale('fontSz',8,'scaleFac',1.0,'lineW',.25,'markSz',4); 

% -- preps
% what should be the length of time stretches (seconds) represented per subplot? 
tps=1.09999;
% number of subplots per page
nspp=20;
nspp=15;
nspp=3;

markSz=10;
mCol='y';

% distance to paper border (to long edge, y axis in these plots)
lbordMarg=.02;
% distances to paper border (to short edge, x axis in these plots):
% asymmetric (depends on printer)
sbordMarg=[.045 .025];
% y distance between subplots
marg=.007;
% y extent of each subplot on page
sye=(1-2*lbordMarg-(nspp-1)*marg)/nspp;
% x extent of subplots on page
sxe=1-sum(sbordMarg);
% calculate intervals to be covered by subplots...
[intrvls,nix,intrvlLen]=mkintrvls([boe eoe]*.001,'resol',osi*1e-6,'ilen',tps,'olap',0,'border','include');
% ..and from their number the number of figure pages
nIntrvls=size(intrvls,1);
nFig=ceil(nIntrvls/nspp);
% local copy of p_etls with time column in seconds
bp_etsl=p_etsl;
bp_etsl(:,etslc.tsCol)=bp_etsl(:,etslc.tsCol)*.001;
pcIdx=AP.pcIdx;
pcInd=AP.pcInd;
% -- calculations
load(WP.thetaPFn);
pp_nppc=repmat(nan,1,nLFPCh);
np_nppc=repmat(nan,1,nLFPCh);
for chInd=AP.LFPInd
  % -- positive-going peaks:
  % times of occurrence in s
  pt=.001*posPT{AP.LFPccInd(chInd)};
  tmpi=find(pt>=boe*.001 & pt<eoe*.001);
  % retain number of peaks per channel (see below)
  pp_nppc(chInd)=length(tmpi);
  pp_tpm(1:pp_nppc(chInd),chInd)=pt(tmpi);
  % amplitudes
  pp_apm(1:pp_nppc(chInd),chInd)=posPA{AP.LFPccInd(chInd)}(tmpi);
  % -- negative-going peaks:
  % times of occurrence
  pt=.001*negPT{AP.LFPccInd(chInd)};
  tmpi=find(pt>=boe*.001 & pt<eoe*.001);
  % retain number of peaks per channel (see below)
  np_nppc(chInd)=length(tmpi);
  np_tpm(1:np_nppc(chInd),chInd)=pt(tmpi);
  % amplitudes
  np_apm(1:np_nppc(chInd),chInd)=negPA{AP.LFPccInd(chInd)}(tmpi);
end
clear pt tmpi;
% pp_tpm and pp_tpm accomodate column vectors which originally had different 
% lengths; the zeroes of their zero-padding should be set to nan:
if length(isfinite(unique(pp_nppc)))~=1,
  pp_mnppc=size(pp_tpm,1);
  for chInd=AP.LFPInd
    if pp_nppc(chInd)<pp_mnppc,
      pp_tpm(pp_nppc(chInd)+1:end,chInd)=nan;
    end
  end
end
if length(isfinite(unique(np_nppc)))~=1,
  np_mnppc=size(np_tpm,1);
  for chInd=AP.LFPInd
    if np_nppc(chInd)<np_mnppc,
      np_tpm(np_nppc(chInd)+1:end,chInd)=nan;
    end
  end
end
% (what a heap of code for such a simple task..  )
% invert neg-going peak amplitudes
np_apm=np_apm*-1;
% negative amplitude of pos-going peaks and pos amplitude of neg-going peak 
% will be assigned smallest size: 
pp_apm(pp_apm<=0)=eps;
np_apm(np_apm<=0)=eps;
% scale each channel individually: disregard (in setting the upper limit) 
% amplitudes representing upper .5 % of points since these very likely 
% represent artifacts (which spoil scaling)

pp_co=cumh(pp_apm,.005,'p',[.995]);
np_co=cumh(np_apm,.005,'p',[.995]);

pp_co=ones(size(pp_co))*.5;
np_co=ones(size(np_co))*.5;

% replace amplitudes by marker sizes: largest amplitude of 99.5 % events=8
pp_apm=ceil(markSz*pp_apm./repmat(pp_co,size(pp_apm,1),1));
np_apm=ceil(markSz*np_apm./repmat(np_co,size(np_apm,1),1));
% no blobs from outer space, please: restrict size 
pp_apm(pp_apm>markSz)=markSz;
np_apm(np_apm>markSz)=markSz;

for ii=1:nIntrvls
  % start with fig number 11
  figi=ceil(ii/nspp)+10;
  spi=mod(ii-1,nspp)+1;
  if spi==1, figure(figi), clf, orient landscape, end
  subplot('position',[sbordMarg(1) lbordMarg+(nspp-spi)*(marg+sye) 1-sum(sbordMarg) sye]);
  yl=[.5 nAllLFPCh+.5];     
  % the last interval is most likely shorter than the others, so dont use it to
  % define xlimits of the plot (because that would stretch it)
  xl=intrvls(ii,1)+[0 intrvlLen];
  
  % freeze axis, 'hold' mode, y-axis reversed so that most dorsal electrode is on top
  set(gca,'xlim',xl,'ylim',yl,'NextPlot','add',...
    'XLimMode','manual','YLimMode','manual','xaxisloc','top','ydir','reverse');
  
  if spi==1, 
    yp=yl(1)-diff(yl)*.25;
    % title a little to the left: leave some space for last tick
    th=text(xl(2),yp,[DS.abfFn ', page ' int2str(figi-10) '    ']);
    set(th,'HorizontalAlignment','right','fontsize',8,'fontweight','bold');
  else 
    set(gca,'ytick',[],'xtick',[]); 
    % start of interval
    th=text(xl(1)-diff(xl)*.01,yl(1)+diff(yl)/2,num2str(xl(1)));
    set(th,'rotation',90,'horizontalalignment','center');
  end
  for chInd=AP.LFPInd
    % --- pos peaks:
    % find all points in current interval
    tmpi=find(pp_tpm(:,chInd)>=intrvls(ii,1) & pp_tpm(:,chInd)<intrvls(ii,2));
    % plot each point individually to be able to set its marker size
    for i=tmpi'
      ph=plot(pp_tpm(i,chInd),AP.LFPccInd(chInd),'o');
      set(ph,'markersize',pp_apm(i,chInd),'color',mCol);
    end
    % --- neg peaks:
    % find all points in current interval
    tmpi=find(np_tpm(:,chInd)>=intrvls(ii,1) & np_tpm(:,chInd)<intrvls(ii,2));
    % plot each point individually to be able to set its marker size
    for i=tmpi'
      ph=plot(np_tpm(i,chInd),AP.LFPccInd(chInd),'o');
      set(ph,'markersize',np_apm(i,chInd),'color',mCol,'markerfacecolor',mCol);
    end
  end
  % print?
  if spi==nspp | ii==nIntrvls
    if ~isempty(AP.printas{1}), 
      for i=1:length(AP.printas)
        pa=AP.printas{i};
        if strfind(pa,'ps'), ext='.ps';
        elseif strfind(pa,'jpeg'), ext='.jpg';
        else ext='';
        end
        print(pa,[AP.resPath '\' DS.abfFn '_thPeaks' sprintf('%.2i',figi-10)]); 
      end
      % leave only 3 figures of this sort at any time, closing previous ones
      if figi>13, close(figi-3); end
    end
  end
end

clear pp* np* figi nspp spi ph pcol li bsbix bp_etsl

