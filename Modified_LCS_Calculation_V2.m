 function varargout = Modified_LCS_Calculation_V2(varargin)
%% % LCS_Calculation M-file for LCS_Calculation.fig
% %      LCS_Calculation, by itself, creates a new LCS_Calculation or raises the existing
% %      singleton*.
% %
% %      H = LCS_Calculation returns the handle to a new LCS_Calculation or
% %      the handle to
% %      the existing singleton*.
% %
% %      LCS_Calculation('CALLBACK',hObject,eventData,handles,...) calls the local
% %      function named CALLBACK in LCS_Calculation.M with the given input arguments.
% %
% %      LCS_Calculation('Property','Value',...) creates a new LCS_Calculation or raises the
% %      existing singleton*.  Starting from the left, property value pairs are
% %      applied to the GUI before LCS_Calculation_OpeningFunction gets called.  An
% %      unrecognized property name or invalid value makes property application
% %      stop.  All inputs are passed to LCS_Calculation_OpeningFcn via varargin.
% %
% %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% %      instance to run (singleton)".
% %


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Menu Control.2.Input%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % --------------------------------------------------------------------

LoadOriginalDataMenuItem_Callback

function LoadOriginalDataMenuItem_Callback()

global originaldata_filename originaldata_pathname find_txt find_wk1
% [originaldata_filename, originaldata_pathname, filterindex] = uigetfile({'*.txt';'*.wk1'}, 'MultiSelect', 'on');
originaldata_pathname = ['/Users/mb00k/Desktop/LCS_TEST/Raw_Data' '/'];
 getFolder = dir(fullfile(originaldata_pathname, 'velocity*'));
%getFolder = dir(fullfile(originaldata_pathname, 'data from*'));

originaldata_filename = {getFolder.name};
filterindex = 1;

if iscell(originaldata_filename)==1
    find_txt=max(size(strfind(originaldata_filename{1},'.txt')));
    find_wk1=max(size(strfind(originaldata_filename{1},'.wk1')));
else
    find_txt=max(size(strfind(originaldata_filename,'.txt')));
    find_wk1=max(size(strfind(originaldata_filename,'.wk1')));
end

if find_txt==0 & find_wk1==0
    warndlg('Selection failed. Unknown file format.','error');
end

if filterindex==0
    warndlg('Selection failed. Matlab sometimes fails to a open large number of files. Please select less files.','error');
end
originaldata_filename=sort_char_array(originaldata_filename);

% % --------------------------------------------------------------------

%%
ConvertToMATFilesMenuItem_Callback

function ConvertToMATFilesMenuItem_Callback()

global originaldata_filename originaldata_pathname directory_name find_txt find_wk1

% directory_name = uigetdir('','Select directory of the folder to which MAT files are to be saved');
directory_name = '/Users/mb00k/Desktop/LCS_TEST/Mat_Files';

% prompt = {'Enter the starting frame number:'};
% dlg_title = 'Convert Original Data to Matlab Files';
% num_lines = 1;
% def = {'1'};

% MatFileStartingFrameString = inputdlg(prompt,dlg_title,num_lines,def);
MatFileStartingFrame = 1; %str2num(MatFileStartingFrameString{1});

n_originaldata=length(originaldata_filename);
for i=1:n_originaldata
    i_frame=i+MatFileStartingFrame-1;
    filename=[originaldata_pathname originaldata_filename{i}];
    
    if find_txt==1
        A = dlmread(filename);
    end
    if find_wk1==1
        A = wk1read(filename);
    end
    
%         Lat=A(:,1);
%         Lon=A(:,2);
%         [x,y,utmzone] = deg2utm(Lat,Lon);
%         
%         A(:,1)=x;
%         A(:,2)=y;
        
    
    A = sortrows(A,1);
    B=sortrows(A,2);
    ndata=max(size(A));

    if i==1
        ysize=max(find(A(:,1)==A(1,1)));
        xsize=max(find(B(:,2)==B(1,2)));
        xcoor=B(1:xsize,1);
        ycoor=A(1:ysize,2);

        
        [xloc yloc]=meshgrid(xcoor,ycoor);
        save([directory_name '/xgrid'],'xcoor');
        save([directory_name '/ygrid'],'ycoor');
    end

    for j=1:xsize
        u(1:ysize,j)=A(1+ysize*(j-1):ysize*j,3);
        v(1:ysize,j)=A(1+ysize*(j-1):ysize*j,4);
    end

    expression=['u' num2str(i_frame) '=u'';'];
    eval(expression);
    expression=['v' num2str(i_frame) '=v'';'];
    eval(expression);
    expression=['save(''' directory_name '/U_T' num2str(i_frame) ''',''u' num2str(i_frame) ''');'];
    eval(expression);
    expression=['save(''' directory_name '/V_T' num2str(i_frame) ''',''v' num2str(i_frame) ''');'];
    eval(expression);
    expression=['clear u' num2str(i_frame) ' v' num2str(i_frame) ';'];
    eval(expression);
end

%%

ComputeFTLEMenuItem_Callback

function ComputeFTLEMenuItem_Callback()

global nx ny f_start f_end f_int t_length tstep dt 


% FTLE Type

forward_FTLE = 1;
backward_FTLE = 0;



% FTLE frames Settings
starting_frame = '1';
end_frame = '1';
interval = '1';

% Integration Settings
integration_length = '5';
time_interval = '0.67'; %10800
step_size = '1';

% Calculation Region [X1 X2 Y1 Y2] Settings
% region_x_min = '54.99';%'6.094e+06'; %'199.99'; % 
% region_x_max = '59.99';%'6.654e+06'; %'209.99'; % 
% region_y_min = '199.99';%'3.126e+05'; %'54.99'; % 
% region_y_max = '209.99';%'6.911e+05'; %'59.99'; % 

region_x_min = '199.99'; % 
region_x_max = '209.99'; % 
region_y_min = '54.99'; % 
region_y_max = '59.99'; % 

% Mesh Size
meshsize_x = '200';
meshsize_y = '200';





f_start=str2double(starting_frame);
f_end=str2double(end_frame);
f_int=str2double(interval);
t_length=str2double(integration_length);
tstep=str2double(time_interval);
dt=str2double(step_size);

region_x1=str2double(region_x_min);
region_x2=str2double(region_x_max);
region_y1=str2double(region_y_min);
region_y2=str2double(region_y_max);

nx=str2double(meshsize_x);
ny=str2double(meshsize_y);

forward_calculation=double(forward_FTLE);
backward_calculation=double(backward_FTLE);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%some variables repeated recalled by subroutines are set as global
%variables to save computation time
global xloc yloc xcoor ycoor sxcoor sycoor umesh vmesh directory_name sigma

load([directory_name '/xgrid']);
load([directory_name '/ygrid']);
[xloc yloc]=meshgrid(xcoor,ycoor);
velo_x1=min(xcoor);
velo_x2=max(xcoor);
velo_y1=min(ycoor);
velo_y2=max(ycoor);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sxcoor=linspace(region_x1,region_x2,nx);               % define the initial region of the fluid to track
sycoor=linspace(region_y1,region_y2,ny);         
[xmesh ymesh]=meshgrid(sxcoor,sycoor);
sigma_x=xmesh';                         
sigma_y=ymesh';                         
sigma=zeros(nx,ny);
sigma0=sigma;

CalcFTLE=zeros(nx,ny)+1;                
LeftDomain=zeros(nx,ny);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Forward FTLE Calculation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if forward_calculation==1
    for iT=f_start:f_int:f_end                        % define the time when the FTLE is calculated

        % calculate FTLE at frame # iT
        t_proc = ['T = ', ...
            num2str( iT )];
        disp( t_proc );

        t_start=iT;                         % starting frame
        t_end=t_start+t_length;
        T_start=(t_start-1)*tstep;          % initial time
        T_end=(t_end-1)*tstep;              % end time
        T_span=T_end-T_start;               % integration time length

        sigma_x=xmesh';                     % initial position
        sigma_y=ymesh';

        CalcFTLE=zeros(nx,ny)+1;
        LeftDomain=zeros(nx,ny);

        for t_integration=0:dt:t_length-dt;
            %integrate the flow trajectory from t0 to t1;
            t0=t_start+t_integration;
            t1=t0+dt;

            iiT=t0;
            %%%%%%%%%%%% read the velocity files
            expression=['load(''' directory_name '/U_T' num2str(iiT) '.mat'');'];
            eval(expression);
            expression=['load(''' directory_name '/V_T' num2str(iiT) '.mat'');'];
            eval(expression);
            expression=['umesh=u' num2str(iiT) ';'];
            eval(expression);
            expression=['vmesh=v' num2str(iiT) ';'];
            eval(expression);
            expression=['clear u' num2str(iiT) ' v' num2str(iiT) ';'];
            eval(expression);

            clear X Y T
            %%%%%% if the point is inside, calculate it's trajectory
            [X,Y,T]= RungeKutta_f(t0,t1,tstep,sigma_x,sigma_y);
            sigma_x_new=X;
            sigma_y_new=Y;
            
            for ix=1:nx
                for iy=1:ny
                    clear X Y T
                    %%%%%% if the point is inside, calculate it's trajectory
                    if LeftDomain(ix,iy)==0;

                        % of the point is convected out of the domian,
                        % calculate the FTLE at this point and adjacent points.
                        if (sigma_x_new(ix,iy)-velo_x1)*(sigma_x_new(ix,iy)-velo_x2)>=0 | ...
                                (sigma_y_new(ix,iy)-velo_y1)*(sigma_y_new(ix,iy)-velo_y2)>=0
                            LeftDomain(ix,iy)=1;

                            if CalcFTLE(ix,iy)==1
                                sigma(ix,iy)=calculate_FTLE(ix,iy,sigma_x,sigma_y,T_span);
                                CalcFTLE(ix,iy)=0;

                                if ix>1 & CalcFTLE(ix-1,iy)==1
                                    sigma(ix-1,iy)=calculate_FTLE(ix-1,iy,sigma_x,sigma_y,T_span);
                                    CalcFTLE(ix-1,iy)=0;
                                end
                                if  ix<nx & CalcFTLE(ix+1,iy)==1
                                    sigma(ix+1,iy)=calculate_FTLE(ix+1,iy,sigma_x,sigma_y,T_span);
                                    CalcFTLE(ix+1,iy)=0;
                                end
                                if  iy>1 & CalcFTLE(ix,iy-1)==1
                                    sigma(ix,iy-1)=calculate_FTLE(ix,iy-1,sigma_x,sigma_y,T_span);
                                    CalcFTLE(ix,iy-1)=0;
                                end
                                if  iy<ny & CalcFTLE(ix,iy+1)==1
                                    sigma(ix,iy+1)=calculate_FTLE(ix,iy+1,sigma_x,sigma_y,T_span);
                                    CalcFTLE(ix,iy+1)=0;
                                end

                            end
                        end
                        %%%%%% if the point is outside, don't calculate it's trajectory. keep its position
                    else
                        sigma_x_new(ix,iy)=sigma_x(ix,iy);
                        sigma_y_new(ix,iy)=sigma_y(ix,iy);
                    end
                end
            end

            % update the position for all the points in the domain
            for ix=1:nx
                for iy=1:ny
                    if LeftDomain(ix,iy)==0
                        sigma_x(ix,iy)=sigma_x_new(ix,iy);
                        sigma_y(ix,iy)=sigma_y_new(ix,iy);
                    end
                end
            end
            
            c_frame = (['Frame = ',num2str(iT)]);
            c_proc = strcat( 'process accomplished :  ', ...
                num2str( 100*t_integration/t_length,' %03.0f' ), '/100' );
            disp( c_proc );


        end

        % calculate FTLE for all the points inside the domain at the last
        % time step.
        c_proc = strcat( 'process accomplished :  ', ...
            num2str( 100,' %03.0f' ), '/100' );

        for ix=1:nx
            for iy=1:ny
                if CalcFTLE(ix,iy)==1
                    sigma(ix,iy)=calculate_FTLE(ix,iy,sigma_x,sigma_y,T_span);
                    CalcFTLE(ix,iy)=0;
                end
            end
        end
        
        sigma0=sigma;
        expression=['clear FTLE' num2str(iT)];
        eval(expression);
        expression=['global FTLE' num2str(iT)];
        eval(expression);
        expression=['FTLE' num2str(iT) '=sigma;'];
        eval(expression);
        expression=['save(''' directory_name '/Z_T' num2str(iT) '.mat'');'];
        eval(expression);
        
        


    end
end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% SaveFTLECalculationMenuItem_Callback
% 
% function SaveFTLECalculationMenuItem_Callback()
% 
% global sigma
% [output_file,output_path] = uiputfile('FTLE.txt','Save file name');
% output_FTLE(sigma,output_file,output_path)


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Function sort_char_array%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sortedArr,finalIndex] = sort_char_array(orgArr)


if ischar(orgArr)   %function works with cell array, so if char input, convert to cell array
    tempList = lower(orgArr);
    orgArr = cellstr(orgArr);
else
    tempList = char(lower(orgArr));
end

finalIndex = (1:length(orgArr))';   %create the index vector to be changed
g = {};
for i=1:size(tempList)  %go over all strings and break each one to single letters and numbers
    tempCellArr = breakString(tempList(i,:));   %break one string from the cell array
    g = AssignCellArray(tempCellArr, g);    %add the breaked string to cell matrix
end
%[g,indexes] = SortByColumn2(g,5);
for i=size(g,2):-1:1    %go over cell matrix of breaked strings and sort is from last column to the first

    [g,indexes] = SortByColumn(g,i);    %sort the i column
    
    orgArr = orgArr(indexes);   %update cell array order by the indexes
    finalIndex = finalIndex(indexes);   %update final index order
    
end

sortedArr =orgArr ;


function [sortedArr,indexes] = SortByColumn(arr,column);    
%this function sort each column of the breaked cell-matrix
%sorting is done by converting each textual number to its real value
%and later assign every letter its ascii value plus the maximum of all
%numbers. 
%the sorting is pure numeric (Matlab sort) so numbers are always before
%letters.

tempColumn = zeros(size(arr,1),1);
for i=1:length(tempColumn)
    if ~isempty(str2num(char(arr(i,column)))); %finds all numbers including non-real numbers
        tempColumn(i) = str2num(char(arr(i,column)))+1; %assign numbers to the vactor
    end
end
maxNum = max(tempColumn);
u2 = isletter(char(arr(:,column))); %find all letters
tempColumn(u2) = char(arr(u2,column)) + maxNum; %assign numerical representation of letters that is bigger then the numbers

[tempSort,indexes] = sort(tempColumn);
sortedArr = arr(indexes,:);



function newArr = AssignCellArray(assignmentVector, assignTo)
%this function helps adding cell-arrays to the breaked strings cell-matrix


assignToSize = size(assignTo,2);
assignmentVectorSize = length(assignmentVector);
if assignToSize==0
    newArr = assignmentVector;
    
elseif (assignToSize==assignmentVectorSize)
    newArr = [assignTo;assignmentVector];
elseif (assignToSize>assignmentVectorSize)
    assignmentVector((assignmentVectorSize+1):assignToSize)={' '};
    newArr = [assignTo;assignmentVector];
else
    assignTo(:,(assignToSize+1):assignmentVectorSize)={' '};
    newArr = [assignTo;assignmentVector];
end


function groups = breakString(stringToBreak)
%this function breaks a string to its single letters and numbers,
%producing cell array for a single string.

if ~ischar(stringToBreak)   %convert to char array
    tempString = char(stringToBreak);
else
    tempString=stringToBreak;
end
counter = 1;
i=1;
groups = {};
while i<=length(tempString) %go over all chars in the string
    if  ~isletter(tempString(i)) & isempty(str2num(tempString(i)))   %tempString(i)==' '   %Skip spaces
        i=i+1;
        continue;
    end
    if isempty(str2num(tempString(i)))  %in case of a letter - just add it to the array
        groups(counter)={tempString(i)};
        counter = counter + 1;
        i = i + 1;
    else
        groups(counter) = {tempString(i)};
        i = i+1;
        while (i<=length(tempString) & ~isempty(str2num(tempString(i))))    %in case of number,
            %add it to the array and search for following numbers
            groups(counter)={[char(groups(counter)) tempString(i)]};
            i = i + 1;
        end
        counter = counter + 1;
    end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [X,Y,T]= RungeKutta_f(i_start,i_end,h,xstart,ystart)

% global umesh vmesh

n=1;
t=i_start;
tend=i_end;

delta_i=i_end-i_start;

[ux,uy] = velocity(xstart,ystart,i_start);
x = xstart + delta_i*h*ux;
y = ystart + delta_i*h*uy;
    
X=x;
Y=y;
T=t+1;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Function velocity%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ux,uy] = velocity(x,y,iiT)

global xloc yloc umesh vmesh
    
ux = interp2(xloc,yloc,umesh',x,y,'linear');
uy = interp2(xloc,yloc,vmesh',x,y,'linear');

index=find(isnan(ux)==1);
ux(index)=0;

index=find(isnan(uy)==1);
uy(index)=0;
% 

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Function calculate_FTLE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
function out=calculate_FTLE(ix,iy,flowmap_x,flowmap_y,t_span)

global sxcoor sycoor

[nx ny]=size(flowmap_x);

if (ix-1)*(ix-nx)<0 & (iy-1)*(iy-ny)<0
    A11=(flowmap_x(ix+1,iy)-flowmap_x(ix-1,iy))/(sxcoor(ix+1)-sxcoor(ix-1));
    A12=(flowmap_x(ix,iy+1)-flowmap_x(ix,iy-1))/(sycoor(iy+1)-sycoor(iy-1));
    A21=(flowmap_y(ix+1,iy)-flowmap_y(ix-1,iy))/(sxcoor(ix+1)-sxcoor(ix-1));
    A22=(flowmap_y(ix,iy+1)-flowmap_y(ix,iy-1))/(sycoor(iy+1)-sycoor(iy-1));
    A=[A11 A12;A21 A22];
    B=A'*A;
    delta=max(eig(B));
    out=log(delta)/(2*t_span);
else
    out=0;
end

% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Function output%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=output_FTLE(sigma,file,path)

global sxcoor sycoor f_start f_end f_int

% f_start=str2double(get(handles.starting_frame,'String'));
% f_end=str2double(get(handles.end_frame,'String'));
% f_int=str2double(get(handles.interval,'String'));

%     expression=['save(''sigma_f'',''sigma'');'];
%     eval(expression);
    
[xmesh ymesh]=meshgrid(sxcoor,sycoor);
xloc1=reshape(xmesh(:,:),[],1);
yloc1=reshape(ymesh(:,:),[],1);

filename=[path file];
fid = fopen(filename,'wt');
fprintf(fid,'TITLE = FTLE FIELD\n');
fprintf(fid,'VARIABLES = X, Y, FTLE\n');
for iT=f_start:f_int:f_end
    expression=['global FTLE' num2str(iT) ';'];
    eval(expression);
    expression=['sigma0=FTLE' num2str(iT) ';'];
    eval(expression);

    [nx,ny]=size(sigma0);

    % FTLE FIELD
    Z = sigma0';

    Z1=reshape(Z,[],1);
    dummy=0*Z1;
    data=[xloc1 yloc1 Z1];

    fprintf(fid,['ZONE T=''A' num2str(iT) ''' I=' num2str(ny) ', J=' num2str(nx) ', F=POINT\n']);
    fprintf(fid,'%12.8f %12.8f %12.8f \n',data');
end
fclose(fid);
