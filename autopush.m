function autopush(commitMsg)
    if nargin < 1 || strlength(commitMsg) == 0
        commitMsg = "Auto-update: " + string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
    end

    repo = gitrepo(pwd);

    if ~isempty(repo.UntrackedFiles)
        add(repo, repo.UntrackedFiles);
    end

    [~, statusOut] = system('git status --porcelain');
    if isempty(strtrim(statusOut))
        disp('✔ Everything is already up to date. Nothing to push.');
        return;
    end

    system('git add -u');
    commit(repo, Message=commitMsg);

    disp('Pushing changes to GitHub...');
    try
        push(repo);
        disp("✔ Successfully pushed to GitHub (" + commitMsg + ")");
    catch
        branchName = repo.CurrentBranch.Name;
        [status, cmdOut] = system(sprintf('git push -u origin %s', branchName));
        if status == 0
            disp("✔ Successfully pushed to GitHub on branch: " + branchName);
        else
            error('Push failed. Details:\n%s', cmdOut);
        end
    end
end
