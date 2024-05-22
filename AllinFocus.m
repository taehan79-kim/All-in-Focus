
%% Fourier transform & filter
original_img = imread('B1__tif00165.tiff');
org_img1=im2double(original_img);
[M,N]=size(original_img);
H=hpfilter('gaussian',M,N,4); 
L=lpfilter('gaussian',M,N,150);
BP=H.*L;
la_flt=fspecial('laplacian',0.3);
av_flt=fspecial('average',[15,15]);

%% 확인용 변수
g3=zeros(M,N);
num_focus_mask=zeros(M,N);
g4=zeros(M,N);
add_img=zeros(M,N);
add_img_bpf=zeros(M,N);
background=zeros(M,N);
background_bpf=zeros(M,N);
goblet_img_bpf=zeros(M,N);
num_goblet_mask=zeros(M,N);
tot_goblet_mask=zeros(M,N);
goblet_img_bpf1=zeros(M,N);
color_img=zeros(M,N);
thr_tot=zeros(M,N);

%% main loop
for pq=165:1:245
original_img = imread(strcat('B1__tif00',num2str(pq),'.tiff'));
org_img=im2double(original_img);
background=org_img+background;
F=fft2(original_img);

%% BPF
G=F.*BP;
bpf_img=real(ifft2(G));

min_r=min(bpf_img);
min_v=min(min_r,[],2);
max_r=max(bpf_img);
max_v=max(max_r,[],2);
bpf_img1=(bpf_img-min_v)/(max_v-min_v);

%% filtering
bpf_av=imfilter(bpf_img,av_flt,'symmetric','conv');
flt_img=imfilter(bpf_av,la_flt,'symmetric','conv');

%% Focused Range Slect
g2=zeros(M,N);
r=30;
thr_h=0.18;
thr_l=-0.3;
for i=1+r:1:M-r
    for j=1+r:1:N-r
        if flt_img(i,j)>thr_h
            g2(i,j)=1;
        elseif flt_img(i,j)<thr_l
            g2(i,j)=1;
        end
    end
end

%%
min_r=min(bpf_img);
min_v=min(min_r,[],2);
max_r=max(bpf_img);
max_v=max(max_r,[],2);
bpf_img=(bpf_img-min_v)/(max_v-min_v);
background_bpf=bpf_img+background_bpf;

%% ROI Masking
gaussian_mask = fspecial('gaussian',150,10);
min_r=min(gaussian_mask);
min_v=min(min_r,[],2);
max_r=max(gaussian_mask);
max_v=max(max_r,[],2);
gaussian_mask1=(gaussian_mask-min_v)/(max_v-min_v);
focus_mask=imfilter(g2,gaussian_mask1,'conv');
for i=1:1:2048
    for j=1:1:2048
        if focus_mask(i,j)>1
            focus_mask(i,j)=1;
        end
    end
end

focus_img=focus_mask.*org_img;
focus_img_bpf=focus_mask.*bpf_img;

%% 
add_img=add_img+focus_img;
add_img_bpf=add_img_bpf+focus_img_bpf;

num_focus_mask=num_focus_mask+focus_mask;
end
%% Background Image
background=background/81;  % (original)
background_bpf=background_bpf/81;

%% Image Overlapping
k=1;
final_img=(add_img+(k*background))./(num_focus_mask+k);
final_img_bpf=(add_img_bpf+(k*background_bpf))./(num_focus_mask+k);

figure, imshow(final_img, []);
