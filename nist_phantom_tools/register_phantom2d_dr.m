%
% load dicom file (Octave and Matlab)
%
% geometry processing and roi finder
%

if( is_octave() )
  pkg load dicom
  pkg load image
end

clear all; close all;


prefix = '/home/gimbutas/Telework/rrsg2020/osfstorage/challenge_submissions/'

%% .35 T

%%filename = '0.35T/NIST_phantom/20200229_niloufar_hfmc_NIST/raw/Dicom/10-vti_t1mapping_ti_300/10-1.dcm'


%% 3 T

filename = '3T/NIST_phantom/20200124_siyuanhu_casewestern_NIST/raw/Research_t1_challenge_phantom_20200124_003_SEIR_TI400.IMA'

%%filename = '3T/NIST_phantom/20200121_matthewgrechsollars_ICL_NIST/raw/ISMRM_NIST_DICOM/__20200121_141654_595000/SE_TI400_0004/ISMRM_NIST.MR._.0004.0001.2020.01.21.15.34.48.70727.67291411.IMA'

%%filename = '3T/NIST_phantom/20200203_iveslevesque_muhc_mgh_NIST/raw/DICOM/TI400/NIST_QA.MR.T1_MAPPING_IR.0014.0001.2020.02.03.11.09.14.772258.32529804.IMA'

%%filename = '3T/NIST_phantom/20200204_mrel_usc_NIST/raw/20200204_mrel_usc_GE3T_MR1_NIST/raw/i1302858.MRDC.1'

%%filename = '3T/NIST_phantom/20200204_mrel_usc_NIST/raw/20200204_mrel_usc_GE3T_MR2_NIST/raw/i1111283.MRDC.1'

%%filename = '3T/NIST_phantom/20200210_guillaumegilbert_muhc_NIST/raw/Magnitude/Mag_400 (0002)'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Aachen/MR1/IM_0022'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Berlin/MR1/IM_0006'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Bonn/MR1/IM_0003'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Cologne/MR1/IM_0074'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Cologne/MR3/IM_0041'

%%filename = '3T/NIST_phantom/20200225_CStehningPhilipsClinicalScienceGermany_NIST/raw/Hamburg/MR1/IM_0013'

%%filename = '3T/NIST_phantom/20200226_iveslevesque_muhc_glen_NIST/NoPowerError/raw/DICOM/IM_0050'

%%filename = '3T/NIST_phantom/20200226_iveslevesque_muhc_glen_NIST/PowerError/raw/DICOM/IM_0007'

%%filename = '3T/NIST_phantom/20200227_karakuzu_polymtl_NIST/20191213_UNF/raw/NISTphantom_01/08-t2_tse_dark-fluid_cor (TI 50ms)/NISTphantom_01-0001.dcm'

%%filename = '3T/NIST_phantom/20200227_karakuzu_polymtl_NIST/20200227_MNI/raw/MR.1.3.12.2.1107.5.2.43.167017.2020022709391928466702194'

%%filename = '3T/NIST_phantom/20200227_madelinecarr_lha_NIST/raw/SE_IR_Phantom_400_0004/FEBRUARY_NISTSYSTEM.MR.ISMRM_COMPETITION.0004.0001.2020.02.27.12.06.48.954626.92403829.IMA'

%%filename = '3T/NIST_phantom/20200229_niloufar_hfmc_NIST/raw/Dicom/10-vti_t1mapping_ti_300/10-1.dcm'

%%filename = '3T/NIST_phantom/20200302_wang_MDAnderson_NIST/raw/day1/i5450765.MRDC.7'

%%filename = '3T/NIST_phantom/20200302_wang_MDAnderson_NIST/raw/day2/i5469073.MRDC.9'

%%filename = '3T/NIST_phantom/20200305_ngmaforo_ucla_NIST/raw/raw skyra/T2_TSE_DARK-FLUID_TRA_COR_(400_MS)_SKYRA_0009/PHANTOMT1SKYRA_PHANTOMT1SKYRA.MR.ENNIS_NYASHA.0009.0001.2020.03.05.22.52.41.347699.64044769.IMA'

%%filename = '3T/NIST_phantom/20200309_near_douglas_NIST/raw/dicom/03-09-NEAJAM-NISTPHANTOM_TEST_2020-03-09-NEAJAM-NISTPHANTOM_TEST/SPECTRSCOPY_JAMIE_20200309_101658_432000/T2_TSE_DARK-FLUID_TRA_TI400_0003/2020-03-09-NEAJAM-NISTPHANTOM_TEST.MR.SPECTRSCOPY_JAMIE.0003.0001.2020.03.09.10.36.23.334919.314922064.IMA'


%% T2 array? PD array?
%%filename = '3T/NIST_phantom/20200305_ngmaforo_ucla_NIST/raw/raw prisma/T2_TSE_DARK-FLUID_TRA_COR_(400_MS)_0006/PHANTOMT1_PHANTOMT1.MR.ENNIS_NYASHA.0006.0001.2020.03.05.20.38.06.419098.175845921.IMA'

%% Missing header information in this DICOM 
%%filename = '3T/NIST_phantom/20201802_jalnefjord_sahlgrenska_NIST/raw/DICOM/IM_0011'


disp('')
filename = [prefix, filename]


R = read_dicom_ir(filename);
P = register_phantom2d(R.D);

nmax = size(P.Y,1);
mmax = size(P.Y,2);

dx = P.dx
dy = P.dy
phi = P.phi;
phi_degrees = phi * 180/pi

roi_centers = P.roi_centers_geo
roi_radii = P.roi_radii_geo


ifplot = 1;

if( ifplot == 1 )

  figure;
  imagesc(double(R.D(:,:,1)))
  title('DICOM')
  colormap(gray)
  colormap(jet)
  colorbar

  figure;
  imagesc(double(P.Y))
  colormap(jet)
  colorbar
  title('Image for registration')

  figure;
  imagesc(P.Za)
  colormap(jet)
  colorbar
  title('Edges')

  figure;
  imagesc(P.phantom_mask_init)
  colormap(jet)
  colorbar
  title('Phantom mask, reference')

  figure;
  imagesc(P.phantom_mask_match)
  colormap(jet)
  colorbar
  title('Phantom mask, matched')

  figure;
  imagesc(P.phantom_mask_match .* P.Y )
  colormap(jet)
  colorbar
  title('Image, masked')

  figure;
  imagesc(P.phantom_mask_match .* P.Za )
  colormap(jet)
  colorbar
  title('Edges, masked')

  % extract all regions
  c = zeros(nmax);
  for id = 1:14
    d = cmask(nmax,P.roi_radii_geo(id)*1.2,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + d .* P.Za;
  end
    
  figure;
  imagesc(c)
  colormap(jet)
  colorbar
  title('Edges (detected ROIs, tight)')

  % extract all regions
  c = zeros(nmax);
  for id = 1:14
    b = cmask(nmax,P.mask_radius,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + b .* P.Y;
  end
    
  figure;
  imagesc(c)
  colormap(jet)
  colorbar
  title('Image (detected ROIs)')
    
  % extract all regions
  c = zeros(nmax);
  for id = 1:14
    b = cmask(nmax,P.roi_radii_geo(id),...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + b .* P.Y;
  end
    
  figure;
  imagesc(c)
  title(R.filename)
  colormap(jet)
  colorbar
  title('Image (detected ROIs, tight)')
    
end