function ea_apply_normalization_tofile(options,from,to,directory,useinverse,interp,refim)
% this function applies lead-dbs normalizations to nifti files.
% currently just used to generate patient specific atlases,i.e., from MNI
% space to native space
if ~strcmp(directory(end),filesep)
   directory=[directory,filesep];
end

[options.root,options.patientname]=fileparts(fileparts(directory));
options.root=[options.root,filesep];

if ~exist('interp','var')
    interp=4;
end

if ~exist('refim','var')
    refim='';
end
switch ea_whichnormmethod(directory)
    case ea_getantsnormfuns % ANTs part here

        ea_ants_apply_transforms(options,from,to,useinverse,refim,'',interp);

    case ea_getfslnormfuns % FSL part here
        if useinverse
            for fi=1:length(from) % assume from and to have same length (must have for this to work)
                if strcmp(from{fi}(end-2:end),'.gz') % .gz support
                    wasgz = 1;
                    gunzip(from{fi});
                    delete(from{fi});
                    from{fi} = from{fi}(1:end-3);
                else
                    wasgz = 0;
                end
                [dn,fn]=fileparts(from{fi});
                matlabbatch{1}.spm.util.imcalc.input = {
                    [ea_space(options),options.primarytemplate,'.nii,1']
                    [from{fi},',1']
                    };
                matlabbatch{1}.spm.util.imcalc.output = fn;
                matlabbatch{1}.spm.util.imcalc.outdir = {dn};
                matlabbatch{1}.spm.util.imcalc.expression = 'i2';
                matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
                matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
                matlabbatch{1}.spm.util.imcalc.options.mask = 0;
                matlabbatch{1}.spm.util.imcalc.options.interp=interp;
                matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
                spm_jobman('run',{matlabbatch});
                clear matlabbatch

                if wasgz
                    gzip(from{fi});
                    delete(from{fi});
                    from{fi} = [from{fi}, '.gz'];
                end
            end
        end
        ea_fsl_apply_normalization(options,from,to,useinverse,refim,'',interp);

    otherwise % SPM part here
        for fi=1:length(from) % assume from and to have same length (must have for this to work)
            if strcmp(from{fi}(end-2:end),'.gz') % .gz support
                wasgz = 1;
                [~,fn] = fileparts(from{fi});
                copyfile(from{fi},[tempdir,fn,'.gz']);
                gunzip([tempdir,fn,'.gz']);
                from{fi} = [tempdir,fn];
            else
                wasgz = 0;
            end

            refIsGz = 0;

            usepush=1;
            if useinverse
                if isempty(refim)
                    refim = [directory,options.prefs.prenii_unnormalized];
                elseif endsWith(refim, '.gz')
                    refIsGz = 1;
                    gunzip(refim);
                    refim = strrep(refim, '.gz', '');
                end

                if usepush
                    matlabbatch{1}.spm.util.defs.comp{1}.def = {[directory,'y_ea_normparams.nii']};
                    matlabbatch{1}.spm.util.defs.out{1}.push.fnames = from(fi);
                    matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
                    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {fileparts(to{fi})};
                    matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {refim};
                    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
                    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0.5 0.5 0.5];
                    matlabbatch{1}.spm.util.defs.out{1}.push.prefix = '';
                else
                    matlabbatch{1}.spm.util.defs.comp{1}.def = {[directory,'y_ea_inv_normparams.nii']};
                    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = from(fi);
                    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {fileparts(to{fi})};
                    matlabbatch{1}.spm.util.defs.out{1}.pull.interp = interp;
                    matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
                    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0.5 0.5 0.5];
                    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';
                end
                spm_jobman('run',{matlabbatch});
                clear matlabbatch
            else
                if isempty(refim)
                    spacedef=ea_getspacedef;
                    refim = [ea_space,spacedef.templates{1},'.nii'];
                elseif endsWith(refim, '.gz')
                    refIsGz = 1;
                    gunzip(refim);
                    refim = strrep(refim, '.gz', '');
                end

                if usepush
                    matlabbatch{1}.spm.util.defs.comp{1}.def = {[directory,'y_ea_inv_normparams.nii']};
                    matlabbatch{1}.spm.util.defs.out{1}.push.fnames = from(fi);
                    matlabbatch{1}.spm.util.defs.out{1}.push.weight = {''};
                    matlabbatch{1}.spm.util.defs.out{1}.push.savedir.saveusr = {fileparts(to{fi})};
                    matlabbatch{1}.spm.util.defs.out{1}.push.fov.file = {refim};
                    matlabbatch{1}.spm.util.defs.out{1}.push.preserve = 0;
                    matlabbatch{1}.spm.util.defs.out{1}.push.fwhm = [0.5 0.5 0.5];
                    matlabbatch{1}.spm.util.defs.out{1}.push.prefix = '';
                else
                    matlabbatch{1}.spm.util.defs.comp{1}.def = {[directory,'y_ea_normparams.nii']};
                    matlabbatch{1}.spm.util.defs.out{1}.pull.fnames = from(fi);
                    matlabbatch{1}.spm.util.defs.out{1}.pull.savedir.saveusr = {fileparts(to{fi})};
                    matlabbatch{1}.spm.util.defs.out{1}.pull.interp = interp;
                    matlabbatch{1}.spm.util.defs.out{1}.pull.mask = 1;
                    matlabbatch{1}.spm.util.defs.out{1}.pull.fwhm = [0.5 0.5 0.5];
                    matlabbatch{1}.spm.util.defs.out{1}.pull.prefix = '';
                end
                spm_jobman('run',{matlabbatch});
                clear matlabbatch
            end

            pth = fileparts(to{fi});
            [~, fn, ext] = fileparts(from{fi});

            if strcmp(to{fi}(end-2:end),'.gz')
                to{fi} = to{fi}(1:end-3);
                gzip_output = 1;
            else
                gzip_output = 0;
            end

            try % fails if to is a w prefixed file already
                movefile(fullfile(pth,['sw', fn, ext]),to{fi});
            end

            if refIsGz
                gzip(refim);
                delete(refim);
            end

            if gzip_output
                gzip(to{fi});
                delete(to{fi});
            end

            if wasgz
                ea_delete([tempdir,fn,'.gz']);
                ea_delete([tempdir,fn]);
            end
        end
end
