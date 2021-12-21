function [rgb_image] = sim_demosaicing_simple(varargin)
  
  p = inputParser();
  
  p.addParamValue('iv_image'       , ones(10,10)); 
  p.addParamValue('ISP_pixel_size', 8); 
  p.addParamValue('G_IMG_WIDTH', 7); %768
  p.addParamValue('G_IMG_HEIGHT',7); %512
  
  p.parse(varargin{:});  
  
  iv_image       = p.Results.iv_image;
  ISP_pixel_size = p.Results.ISP_pixel_size;
  G_IMG_WIDTH    = p.Results.G_IMG_WIDTH;
  G_IMG_HEIGHT   = p.Results.G_IMG_HEIGHT;
  
  clear varargin
  
  % R  | GR
  % GB | B
  
  G_at_G_coef  = [  0.0,  0.0,  0.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  0.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  1.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  0.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  0.0,  0.0,  0.0 ];
                         
   G_at_R_coef      = [  0.0,  0.0, -1.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  2.0,  0.0,  0.0 ; ...  
                        -1.0,  2.0,  4.0,  2.0, -1.0 ; ...  
                         0.0,  0.0,  2.0,  0.0,  0.0 ; ...  
                         0.0,  0.0, -1.0,  0.0,  0.0 ];  
                        
   G_at_B_coef      = [  0.0,  0.0, -1.0,  0.0,  0.0 ; ...  
                         0.0,  0.0,  2.0,  0.0,  0.0 ; ...  
                        -1.0,  2.0,  4.0,  2.0, -1.0 ; ...  
                         0.0,  0.0,  2.0,  0.0,  0.0 ; ...  
                         0.0,  0.0, -1.0,  0.0,  0.0 ];   
                        
  R_at_GR_coef                = [  0.0,  0.0,  0.5,  0.0,  0.0 ; ...  %R_at_GR_locations
                              0.0, -1.0,  0.0, -1.0,  0.0 ; ...  
                             -1.0,  4.0,  5.0,  4.0, -1.0 ; ...  
                              0.0, -1.0,  0.0, -1.0,  0.0 ; ...  
                              0.0,  0.0,  0.5,  0.0,  0.0 ];   
                              
  R_at_GB_coef = R_at_GR_coef';                 
                        
  R_at_B_coef            = [  0.0,  0.0, -1.5,  0.0,  0.0 ; ...  
                         0.0,  2.0,  0.0,  2.0,  0.0 ; ...  
                        -1.5,  0.0,  6.0,  0.0, -1.5 ; ...  
                         0.0,  2.0,  0.0,  2.0,  0.0 ; ...  
                         0.0,  0.0, -1.5,  0.0,  0.0 ];                  
                                                
  B_at_GB_coef = R_at_GR_coef; 
  B_at_GR_coef = R_at_GB_coef;                      
  B_at_R_coef  = R_at_B_coef;    
  
  %Apply filters N reconstruct the image
  %shape = 'full';
  shape = 'same';
  
  sv_image_tmp_G_at_G  = conv2(iv_image, G_at_G_coef , shape);  uint16(sv_image_tmp_G_at_G); %g0
  sv_image_tmp_G_at_R = floor(conv2(iv_image, G_at_R_coef,   shape)./8); uint16(sv_image_tmp_G_at_R); %g1 
  sv_image_tmp_G_at_B = floor(conv2(iv_image, G_at_B_coef, shape)./8); uint16(sv_image_tmp_G_at_B); %g2 
  
  sv_image_tmp_R_at_R  = conv2(iv_image, G_at_G_coef , shape);      uint16(sv_image_tmp_R_at_R); 
  sv_image_tmp_R_at_GR = floor(conv2(iv_image, R_at_GR_coef, shape)./8);   uint16(sv_image_tmp_R_at_GR);    %r0
  sv_image_tmp_R_at_GB = floor(conv2(iv_image, R_at_GB_coef , shape)./8); uint16(sv_image_tmp_R_at_GB);  %r1
  sv_image_tmp_R_at_B  = floor(conv2(iv_image, R_at_B_coef , shape)./8);   uint16(sv_image_tmp_R_at_B);  %r2
  
  sv_image_tmp_B_at_B  = conv2(iv_image, G_at_G_coef , shape);      uint16(sv_image_tmp_B_at_B); 
  sv_image_tmp_B_at_GB = floor(conv2(iv_image, B_at_GB_coef, shape)./8);   uint16(sv_image_tmp_B_at_GB);    %b0
  sv_image_tmp_B_at_GR  = floor(conv2(iv_image, B_at_GR_coef , shape)./8); uint16(sv_image_tmp_B_at_GR);  %b1
  sv_image_tmp_B_at_R  = floor(conv2(iv_image, B_at_R_coef , shape)./8);   uint16(sv_image_tmp_B_at_R);  %b2
  
  %reconstruct the image
  sv_image_R           = uint16(zeros(size(sv_image_tmp_R_at_R))); 
  sv_image_G           = uint16(zeros(size(sv_image_tmp_G_at_G))); 
  sv_image_B           = uint16(zeros(size(sv_image_tmp_B_at_B))); 
  
  R__mask = zeros(size(sv_image_R)); R__mask(1:2:end, 1:2:end) = 1; R__mask = logical(R__mask);
  GR_mask = zeros(size(sv_image_R)); GR_mask(1:2:end, 2:2:end) = 1; GR_mask = logical(GR_mask);
  GB_mask = zeros(size(sv_image_R)); GB_mask(2:2:end, 1:2:end) = 1; GB_mask = logical(GB_mask);
  B__mask = zeros(size(sv_image_R)); B__mask(2:2:end, 2:2:end) = 1; B__mask = logical(B__mask);
  
  sv_image_R(R__mask) = sv_image_tmp_R_at_R ( R__mask);
  sv_image_R(GR_mask) = sv_image_tmp_R_at_GR( GR_mask);
  sv_image_R(GB_mask) = sv_image_tmp_R_at_GB( GB_mask);
  sv_image_R(B__mask)  = sv_image_tmp_R_at_B( B__mask);
  
  sv_image_G(GR_mask) = sv_image_tmp_G_at_G(GR_mask );
  sv_image_G(GB_mask) = sv_image_tmp_G_at_G(GB_mask );
  sv_image_G(R__mask) = sv_image_tmp_G_at_R(R__mask );
  sv_image_G(B__mask) = sv_image_tmp_G_at_B(B__mask );
  
  sv_image_B(B__mask) = sv_image_tmp_B_at_B( B__mask);
  sv_image_B(GR_mask) = sv_image_tmp_B_at_GR( GR_mask);
  sv_image_B(GB_mask) = sv_image_tmp_B_at_GB( GB_mask);
  sv_image_B(R__mask) = sv_image_tmp_B_at_R( R__mask);
  
  sv_image_R = max(sv_image_R,                  0);
  sv_image_R = min(sv_image_R, 2^ISP_pixel_size-1); 
  sv_image_G = max(sv_image_G,                  0);
  sv_image_G = min(sv_image_G, 2^ISP_pixel_size-1); 
  sv_image_B = max(sv_image_B,                  0);
  sv_image_B = min(sv_image_B, 2^ISP_pixel_size-1); 
  
  rgb_image(:,:,1) = sv_image_R;
  rgb_image(:,:,2) = sv_image_G;
  rgb_image(:,:,3) = sv_image_B;
  
  rgb_image(1:2, :, 1:3) = 0;
  rgb_image(G_IMG_HEIGHT -1:G_IMG_HEIGHT, :, 1:3) = 0;
  
  rgb_image(:, 1:2, 1:3) = 0;
  rgb_image(:, G_IMG_WIDTH-1:G_IMG_WIDTH, 1:3) = 0;
  
  end;