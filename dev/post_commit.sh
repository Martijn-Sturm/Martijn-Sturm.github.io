#!/bin/bash

# In case you want to spawn a new terminal that is kept open after execution
# The following should be in the git hook:
# gnome-terminal --window-with-profile=noclose -- /home/martijn/repos/portfolio_dev/dev/post_commit.sh
# The 'noclose' profile has te exist in gnome-terminal beforehand

# portfolio_dev repository path
PORTFOLIO_DEV_PATH="/home/martijn/repos/portfolio_dev"

# github_pages repository path
GITHUB_PAGES_PATH="/home/martijn/repos/Martijn-Sturm.github.io"

end_message() {
    echo ""
    echo "===== END OF POST COMMIT NOTIFICATIONS ====="
    echo ""
}

trap end_message EXIT

echo ""
echo ""
echo ""
echo "===== POST COMMIT BEING EXECUTED ====="
echo ""

check_if_directories_exist() {
    if [ ! -d "$PORTFOLIO_DEV_PATH" ]
    then
        echo "'$PORTFOLIO_DEV_PATH' does not exist on your filesystem."
        exit 1
    fi
    if [ ! -d "$PORTFOLIO_DEV_PATH/_site" ]
    then
        echo "'$PORTFOLIO_DEV_PATH/_site' does not exist on your filesystem."
        echo "Check if the site directory needs to be populated"
        exit 1
    fi
    if [ ! -d "$GITHUB_PAGES_PATH" ]
    then
        echo "'$GITHUB_PAGES_PATH' does not exist on your filesystem."
        exit 1
    fi
}
check_if_in_portfolio_dev_repo() {
    if [ "$(pwd)" != "$PORTFOLIO_DEV_PATH" ]
    then 
        echo "Not in portfolio development directory."
        echo "pwd: " 
        echo $(pwd)
        exit 1
    fi
}
check_if_in_publish_branch() {    
    local branchname=$(git branch --show-current)

    if [ "$branchname" = "publish" ]
    then
        echo "Commited in 'publish' branch:"
        echo "Publish update website is initiated"
    else
        echo "Pushed in branch $branchname"
        echo "Which is not 'publish', hence:"
        echo "No website publish attempted"
        exit 0
    fi
}

add_commit_and_register_site_changes() {
    local commit_message="$1"

    # Stage all static site files
    git add . -A
    # Commit them
    commit_notifications=$(git commit -m "$commit_message")
    # Write notifications to file:
    local FILENAME="$commit_message $(date)"
    local FILEPATH="$GITHUB_PAGES_PATH/commit_logs/$FILENAME.txt"
    local FILEPATH=${FILEPATH// /_}
    echo "$commit_notifications" > "$FILEPATH"
    echo "Commit notifications writen to $FILEPATH"
}

check_git_status_for_other_changes() {
    git_status_n_lines=$(git status --porcelain=v2 2>/dev/null | wc -l)
    # > 0 means other changes
    if [ $git_status_n_lines -gt 0 ]
    then
        echo "There are other changes in the Github Pages repo (at: $GITHUB_PAGES_PATH). No publish executed. Commit reset at Github pages repo is reset"
        echo "git status:"
        echo $(git status --porcelain=v2)
        git reset --soft HEAD~1
        exit 1
    else
        echo "No other changes in Github Pages repo found other than site changes. Publish continues"
    fi
}


push_website_update_to_remote() {
    local git_push_notification=$(git push 2>&1 > /dev/null)
    # echo $git_push_notification
    local git_push_exit_code=$?
    # echo $git_push_exit_code

    if [ "$git_push_exit_code" -eq 1 ]
    then
        echo "Git push failed"
        echo "message:"
        echo "$git_push_notification"
    elif [ "$git_push_exit_code" -eq 0 ]
    then
        echo "Git push succeeded"
        echo "Changes to website haven been pushed. Message:"
        echo "$git_push_notification"
    else
        echo "Unknown git push exit code:"
        echo "$git_push_exit_code"
    fi
    exit $git_push_exit_code
}


cd $PORTFOLIO_DEV_PATH

check_if_directories_exist

check_if_in_portfolio_dev_repo

check_if_in_publish_branch

commit_message=$(git log -1 --pretty=%B)


# Copy template to restore empty template later:
cp -r "$GITHUB_PAGES_PATH/.template/." "$GITHUB_PAGES_PATH/new_site"

# Copy _site built files to github_pages repo temporary new_site folder
cp -r "$PORTFOLIO_DEV_PATH/_site/." "$GITHUB_PAGES_PATH/new_site"

# Copy template folder to main folder
cp -r "$GITHUB_PAGES_PATH/new_site/." "$GITHUB_PAGES_PATH"

# delete temp new_site
rm -r "$GITHUB_PAGES_PATH/new_site"

# Move to github pages repo
cd $GITHUB_PAGES_PATH

add_commit_and_register_site_changes "$commit_message"

check_git_status_for_other_changes

push_website_update_to_remote
