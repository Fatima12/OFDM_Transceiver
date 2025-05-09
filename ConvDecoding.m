function [ fbit ] = ConvDecoding( rcvd , m )

n = 2;
k = 1;
mm=m+1;
Num_of_States=2^m;%total number of states
g{1} = [1 0 1 1 0 1 1];                % Impulse Responses _ 1
g{2} = [1 1 1 1 0 0 1];                % Impulse Responses _ 2  
G_great=[1 0 1 1 0 1 1 1 1 1 1 0 0 1];
b=0;

ns_a=zeros(1,Num_of_States);
ns_b=zeros(1,Num_of_States);
op_a=zeros(1,Num_of_States);
op_b=zeros(1,Num_of_States);
op_aa=zeros(1,n);
op_bb=zeros(1,n);
%States are mentioned in order of 0,1,2,3 like:
%00-state 0
%10-state 1
%01-state 2
for i=1:Num_of_States   
    convt=de2bi(i-1,m); %BIN states from 0 to m-1-> MSB to LSB
    ns_aa=[0,convt(1:m-1)];%tells what wd next state be if 0 i/p
    ns_a(1,i)=bi2de(ns_aa);%bi2de of abv
    ns_bb=[1,convt(1:m-1)];%tells what state wd be if 1 i/p
    ns_b(1,i)=bi2de(ns_bb);%bi2de of that abv
    x1=[0,convt];
    x2=[1,convt];
    for j=1:1:n
        op_aa(1,j)=mod(sum(x1.*G_great(1+b:mm+b)),2);%generating o/p
        op_bb(1,j)=mod(sum(x2.*G_great(1+b:mm+b)),2);%generating o/p
        b=b+mm;
    end
    b=0;
    op_a(1,i)=bi2de(op_aa);%o/p at that state corres. to 0 i/p
    op_b(1,i)=bi2de(op_bb);%o/p at that state corres. to 1 i/p
end

b = 0;
input=zeros(1,length(rcvd)/n);
small_flag=zeros(1,length(rcvd)/n);

for i=1:length(rcvd)/n
    if rcvd(b+1)~=Inf && rcvd(b+n)~=Inf
    input(1,i)=bi2de(rcvd(b+1:n+b));%%grouping rcvd vector in 
    b=b+n;                          %%decimal words
    elseif (rcvd(b+1)~=Inf && rcvd(b+n)==Inf)
    rcvd(b+n)=0;
    input(1,i)=bi2de(rcvd(b+1:n+b));%%grouping rcvd vector in 
    b=b+n;                          %%decimal words
    small_flag(1,i)=1;
    elseif (rcvd(b+1)==Inf && rcvd(b+n)~=Inf)
    rcvd(b+1)=0;    
    punc1=rcvd(b+1);
    punc2=rcvd(n+b);
    input(1,i)=bi2de([punc2,punc1]);%%SPECIAL 3/4 puncturing for every third tuple
    b=b+n;
    small_flag(1,i)=2;
    else
    input(1,i)=Inf;
    b=b+n;
    end
end
input;
%%%%
H_D_a=zeros(length(rcvd)/n,Num_of_States);
H_D_b=zeros(length(rcvd)/n,Num_of_States);


for j=0:(length(rcvd)/n)-1
    
    if input(1,j+1)~=Inf && small_flag(1,j+1)==0 %regular trellis for non-punctured tuples,0-3-6-9 
        for i=1:Num_of_States
            H_D_a(j+1,i)=hamm_dist(op_a(1,i),input(1,j+1));
            H_D_b(j+1,i)=hamm_dist(op_b(1,i),input(1,j+1));
        end %%%Hamming Distances go in rows...so see Hamming distnaces
        
    elseif input(1,j+1)~=Inf && small_flag(1,j+1)==1 %NEW trelis for punctured tuples 1-4-7
        for i=1:Num_of_States
            work1=de2bi(op_a(1,i));
            work11=work1.*[1 0];
            op_a11=bi2de(work11);
            
            work2=de2bi(op_b(1,i));
            work22=work2.*[1 0];
            op_b11=bi2de(work22);
            
            H_D_a(j+1,i)=hamm_dist(op_a11,input(1,j+1));
            H_D_b(j+1,i)=hamm_dist(op_b11,input(1,j+1));
        end %%%Hamming Distances go in rows...so see Hamming distnaces
    elseif input(1,j+1)~=Inf && small_flag(1,j+1)==2
        for i=1:Num_of_States %NEW trelis for punctured tuples 2-5-8
            work1=de2bi(op_a(1,i),2);
            work11=work1.*[0 1];
            op_a11=bi2de([work11(1,2) work11(1,1)]);
            
            work2=de2bi(op_b(1,i),2);
            work22=work2.*[0 1];
            op_b11=bi2de([work22(1,2) work22(1,1)]);
            H_D_a(j+1,i)=hamm_dist(op_a11,input(1,j+1));
            H_D_b(j+1,i)=hamm_dist(op_b11,input(1,j+1));
        end %%%Hamming Distances go in rows...so see Hamming distnaces
    else
        for i=1:Num_of_States
            H_D_a(j+1,i)=0;
            H_D_b(j+1,i)=0;
        end
    end
    b=b+n;%%%%%at each state in a row. # of cols=# of states
end                            %%%     # of rows=# of rcvd/n
H_D_a;%H.D. corr. to i/p branches
H_D_b;%H.D. corr. to o/p branches
%%%%
%*********************Beginning of Computing AEM*******************%
ini_path_dist=[0 Inf.*ones(1,Num_of_States-1)];%First AEM (initialization)
ini_path_dist2=[0 Inf.*ones(1,Num_of_States-1)];%could be removed
aem=ini_path_dist;
v=0;
err2=zeros(Num_of_States,(2^k*length(rcvd)/n));
for i=1:length(input)%input is decimal colection of rcvd/n bits
  for j=0:Num_of_States-1 %4
        ns_a;
        pos1=find(ns_a==j);%find kin kin ki next state i=0/2/4 hai
        ns_b;
        pos2=find(ns_b==j);%find kin kin ki next state 1=1/3/5 hai
        
        err=zeros(1,length(pos1));
        if isempty(pos1)
            %do nothing bcz
            %this means we have to sum i/p due to 1
        else
            for p=1:length(pos1)
                err(1,p)=H_D_a(i,pos1(p));%getting H.D. to ith next state
                err(1,p)=ini_path_dist(1,pos1(p))+err(1,p);%adding them to prev. metric

            end
        end
            
        if isempty(pos2)
            %do nothing bcz
            %this means we have to sum i/p due to 0
        else
            for p=1:length(pos2)
                err(1,p+length(pos1))=H_D_b(i,pos2(p));
                err(1,p)=ini_path_dist(1,pos2(p))+err(1,p);
            end
        end

        for d=1:length(err)
                err2(j+1,d+v)=err(1,d);%%%see notebook for exp.
        end
    aem(i,j+1)=min(err);
   end
    v=v+length(err); 
    ini_path_dist=aem(i,:);
end
err2=[ini_path_dist2' err2];
aem;
%*************************Beginning of Traceback********************%
fbit=zeros(1,length(input));
j=2^k*length(input)+1;%is it 2^k*length(rcvd)/n+1 ???
p=size(aem);%get size of aem
            p=p(1,1);%get the # of rows of aem
            [C,I]=(min(aem(p,:)));%Neg C+start from the last state and find min. metric
            parent=I-1;%once found min;subt 1 to know which state from 
                      %bcz states are defined form 0 to Num_of_states-1
inc=0;
for i=0:length(input)-1%for all coded rcvd/n bits
        C1=err2(parent+1,j);
            j=j-1;
        C2=err2(parent+1,j);
            j=j-1;
        ff=find(C1>=C2);%comparing metric at each state
        
        if isempty(ff)
            small=C1;   %which one is smaller?
        else
            small=C2;
        end
        
        parent1=find(ns_a==parent);%who is the parent of the current stsate?
        parent2=find(ns_b==parent);
        
        if isempty(parent2)%means its an even state 0/2/4 we 
                           %are trying to find parent of
            if ff==1 %even state+C1 is greater
            parent11=parent1(1,1)-1;
            parent22=[];
            else     %even state+C2 is greater
            parent11=parent1(1,2)-1;
            parent22=[];
            end
        else
            if ff==1 %even state+C1 is greater
            parent22=parent2(1,1)-1;
            parent11=[];
            else     %even state+C2 is greater
            parent22=parent2(1,2)-1;
            parent11=[];
            end
        end
        
        if isempty(parent11)
            fbit(1,length(input)-inc)=1;
            parent=parent22;
            inc=inc+1;
        else 
            fbit(1,length(input)-inc)=0;
            parent=parent11;
            inc=inc+1;
        end
end
inc=0;
fbit;


end

