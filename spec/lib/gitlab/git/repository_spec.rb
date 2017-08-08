  include Gitlab::Git::EncodingHelper
  let(:repository) { Gitlab::Git::Repository.new(TEST_REPO_PATH) }
    it { is_expected.to respond_to(:raw) }
  describe :branch_names do
  describe :tag_names do
  describe :archive do
  describe :archive_zip do
  describe :archive_bz2 do
  describe :archive_fallback do
  describe :size do
  describe :has_commits? do
  describe :empty? do
  describe :bare? do
  describe :heads do
    let(:heads) { repository.heads }
    subject { heads }

    it { is_expected.to be_kind_of Array }

    describe '#size' do
      subject { super().size }
      it { is_expected.to eq(SeedRepo::Repo::BRANCHES.size) }
    end

    context :head do
      subject { heads.first }

      describe '#name' do
        subject { super().name }
        it { is_expected.to eq("feature") }
      end

      context :commit do
        subject { heads.first.dereferenced_target.sha }

        it { is_expected.to eq("0b4bc9a49b562e85de7cc9e834518ea6828729b9") }
      end
    end
  end

  describe :ref_names do
  describe :search_files do
    let(:results) { repository.search_files('rails', 'master') }
    subject { results }
    it { is_expected.to be_kind_of Array }
    describe '#first' do
      subject { super().first }
      it { is_expected.to be_kind_of Gitlab::Git::BlobSnippet }
    context 'blob result' do
      subject { results.first }
      describe '#ref' do
        subject { super().ref }
        it { is_expected.to eq('master') }
      end

      describe '#filename' do
        subject { super().filename }
        it { is_expected.to eq('CHANGELOG') }
      end
      describe '#startline' do
        subject { super().startline }
        it { is_expected.to eq(35) }
      end
      describe '#data' do
        subject { super().data }
        it { is_expected.to include "Ability to filter by multiple labels" }
      end
  context :submodules do
    let(:repository) { Gitlab::Git::Repository.new(TEST_REPO_PATH) }
      let(:submodules) { repository.submodules('master') }
            "path" => "six",
        expect(nested['path']).to eq('nested/six')
        expect(nested['path']).to eq('deeper/nested/six')
        submodules = repository.submodules('fix-existing-submodule-dir')
        submodules = repository.submodules('v1.2.1')
            "path" => "six",
      let(:submodules) { repository.submodules('6d39438') }
  describe :commit_count do
    it { expect(repository.commit_count("master")).to eq(25) }
    it { expect(repository.commit_count("feature")).to eq(9) }
  end

  describe "#reset" do
    change_path = File.join(TEST_NORMAL_REPO_PATH, "CHANGELOG")
    untracked_path = File.join(TEST_NORMAL_REPO_PATH, "UNTRACKED")
    tracked_path = File.join(TEST_NORMAL_REPO_PATH, "files", "ruby", "popen.rb")

    change_text = "New changelog text"
    untracked_text = "This file is untracked"

    reset_commit = SeedRepo::LastCommit::ID

    context "--hard" do
      before(:all) do
        # Modify a tracked file
        File.open(change_path, "w") do |f|
          f.write(change_text)
        end

        # Add an untracked file to the working directory
        File.open(untracked_path, "w") do |f|
          f.write(untracked_text)
        end

        @normal_repo = Gitlab::Git::Repository.new(TEST_NORMAL_REPO_PATH)
        @normal_repo.reset("HEAD", :hard)
      end

      it "should replace the working directory with the content of the index" do
        File.open(change_path, "r") do |f|
          expect(f.each_line.first).not_to eq(change_text)
        end

        File.open(tracked_path, "r") do |f|
          expect(f.each_line.to_a[8]).to include('raise RuntimeError, "System commands')
        end
      end

      it "should not touch untracked files" do
        expect(File.exist?(untracked_path)).to be_truthy
      end

      it "should move the HEAD to the correct commit" do
        new_head = @normal_repo.rugged.head.target.oid
        expect(new_head).to eq(reset_commit)
      end

      it "should move the tip of the master branch to the correct commit" do
        new_tip = @normal_repo.rugged.references["refs/heads/master"].
          target.oid

        expect(new_tip).to eq(reset_commit)
      end

      after(:all) do
        # Fast-forward to the original HEAD
        FileUtils.rm_rf(TEST_NORMAL_REPO_PATH)
        ensure_seeds
      end
  end

  describe "#checkout" do
    new_branch = "foo_branch"

    context "-b" do
      before(:all) do
        @normal_repo = Gitlab::Git::Repository.new(TEST_NORMAL_REPO_PATH)
        @normal_repo.checkout(new_branch, { b: true }, "origin/feature")
      end
      it "should create a new branch" do
        expect(@normal_repo.rugged.branches[new_branch]).not_to be_nil
      end

      it "should move the HEAD to the correct commit" do
        expect(@normal_repo.rugged.head.target.oid).to(
          eq(@normal_repo.rugged.branches["origin/feature"].target.oid)
        )
      end

      it "should refresh the repo's #heads collection" do
        head_names = @normal_repo.heads.map { |h| h.name }
        expect(head_names).to include(new_branch)
      end

      after(:all) do
        FileUtils.rm_rf(TEST_NORMAL_REPO_PATH)
        ensure_seeds
    context "without -b" do
      context "and specifying a nonexistent branch" do
        it "should not do anything" do
          normal_repo = Gitlab::Git::Repository.new(TEST_NORMAL_REPO_PATH)

          expect { normal_repo.checkout(new_branch) }.to raise_error(Rugged::ReferenceError)
          expect(normal_repo.rugged.branches[new_branch]).to be_nil
          expect(normal_repo.rugged.head.target.oid).to(
            eq(normal_repo.rugged.branches["master"].target.oid)
          )

          head_names = normal_repo.heads.map { |h| h.name }
          expect(head_names).not_to include(new_branch)
        end

        after(:all) do
          FileUtils.rm_rf(TEST_NORMAL_REPO_PATH)
          ensure_seeds
        end
      end

      context "and with a valid branch" do
        before(:all) do
          @normal_repo = Gitlab::Git::Repository.new(TEST_NORMAL_REPO_PATH)
          @normal_repo.rugged.branches.create("feature", "origin/feature")
          @normal_repo.checkout("feature")
        end

        it "should move the HEAD to the correct commit" do
          expect(@normal_repo.rugged.head.target.oid).to(
            eq(@normal_repo.rugged.branches["feature"].target.oid)
          )
        end

        it "should update the working directory" do
          File.open(File.join(TEST_NORMAL_REPO_PATH, ".gitignore"), "r") do |f|
            expect(f.read.each_line.to_a).not_to include(".DS_Store\n")
          end
        end

        after(:all) do
          FileUtils.rm_rf(TEST_NORMAL_REPO_PATH)
          ensure_seeds
        end
      end
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
    it "should update the repo's #heads collection" do
      expect(@repo.heads).not_to include("feature")
    end

      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      @repo.remote_add("new_remote", SeedHelper::GITLAB_URL)
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
    before(:all) do
      repo = Gitlab::Git::Repository.new(TEST_REPO_PATH).rugged
      commit_with_old_name = new_commit_edit_old_file(repo)
      rename_commit = new_commit_move_file(repo)
      commit_with_new_name = new_commit_edit_new_file(repo)
      options = { ref: "master", follow: true }
        let(:log_commits) do
          repository.log(options.merge(path: "encoding"))
        end
        it "should not follow renames" do
          expect(log_commits).to include(commit_with_new_name)
          expect(log_commits).to include(rename_commit)
          expect(log_commits).not_to include(commit_with_old_name)
        let(:log_commits) do
          repository.log(options.merge(path: "encoding/CHANGELOG"))
        it "should follow renames" do
          expect(log_commits).to include(commit_with_new_name)
          expect(log_commits).to include(rename_commit)
          expect(log_commits).to include(commit_with_old_name)
        let(:log_commits) do
          repository.log(options.merge(path: "CHANGELOG"))
        end
        it "should not follow renames" do
          expect(log_commits).to include(commit_with_old_name)
          expect(log_commits).to include(rename_commit)
          expect(log_commits).not_to include(commit_with_new_name)
        let(:log_commits) { repository.log(options.merge(ref: 'unknown')) }
        it "should return empty" do
      let(:commits_by_walk) { repository.log(options).map(&:oid) }
      let(:commits_by_shell) { repository.log(options.merge({ disable_walk: true })).map(&:oid) }
        satisfy do
          commits.all? { |commit| commit.created_at >= options[:after] }
        satisfy do
          commits.all? { |commit| commit.created_at <= options[:before] }
    after(:all) do
      # Erase our commits so other tests get the original repo
      repo = Gitlab::Git::Repository.new(TEST_REPO_PATH).rugged
      repo.references.update("refs/heads/master", SeedRepo::LastCommit::ID)
  describe "#commits_between" do
        expect(repository.commits_between(first_sha, second_sha).count).to eq(3)
        expect(repository.commits_between(sha, branch).count).to eq(5)
        expect(repository.commits_between(branch, sha).count).to eq(0) # sha is before branch
        expect(repository.commits_between(first_branch, second_branch).count).to eq(17)
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      File.open(File.join(TEST_MUTABLE_REPO_PATH, '.git', 'config')) do |config_file|
  describe '#branches with deleted branch' do
    before(:each) do
      ref = double()
      allow(ref).to receive(:name) { 'bad-branch' }
      allow(ref).to receive(:target) { raise Rugged::ReferenceError }
      allow(repository.rugged).to receive(:branches) { [ref] }
    it 'should return empty branches' do
      expect(repository.branches).to eq([])
  end
  describe '#branch_count' do
    before(:each) do
      valid_ref   = double(:ref)
      invalid_ref = double(:ref)

      allow(valid_ref).to receive_messages(name: 'master', target: double(:target))

      allow(invalid_ref).to receive_messages(name: 'bad-branch')
      allow(invalid_ref).to receive(:target) { raise Rugged::ReferenceError }

      allow(repository.rugged).to receive_messages(branches: [valid_ref, invalid_ref])
    it 'returns the number of branches' do
      expect(repository.branch_count).to eq(1)
  describe '#mkdir' do
    let(:commit_options) do
      {
        author: {
          email: 'user@example.com',
          name: 'Test User',
          time: Time.now
        },
        committer: {
          email: 'user@example.com',
          name: 'Test User',
          time: Time.now
        },
        commit: {
          message: 'Test message',
          branch: 'refs/heads/fix',
        }
      }
    end

    def generate_diff_for_path(path)
      "diff --git a/#{path}/.gitkeep b/#{path}/.gitkeep
new file mode 100644
index 0000000..e69de29
--- /dev/null
+++ b/#{path}/.gitkeep\n"
    end

    shared_examples 'mkdir diff check' do |path, expected_path|
      it 'creates a directory' do
        result = repository.mkdir(path, commit_options)
        expect(result).not_to eq(nil)

        # Verify another mkdir doesn't create a directory that already exists
        expect{ repository.mkdir(path, commit_options) }.to raise_error('Directory already exists')
    end
    describe 'creates a directory in root directory' do
      it_should_behave_like 'mkdir diff check', 'new_dir', 'new_dir'
    end
    describe 'creates a directory in subdirectory' do
      it_should_behave_like 'mkdir diff check', 'files/ruby/test', 'files/ruby/test'
    end
    describe 'creates a directory in subdirectory with a slash' do
      it_should_behave_like 'mkdir diff check', '/files/ruby/test2', 'files/ruby/test2'
    describe 'creates a directory in subdirectory with multiple slashes' do
      it_should_behave_like 'mkdir diff check', '//files/ruby/test3', 'files/ruby/test3'
    end
    describe 'handles relative paths' do
      it_should_behave_like 'mkdir diff check', 'files/ruby/../test_relative', 'files/test_relative'
    end
    describe 'creates nested directories' do
      it_should_behave_like 'mkdir diff check', 'files/missing/test', 'files/missing/test'
    it 'does not attempt to create a directory with invalid relative path' do
      expect{ repository.mkdir('../files/missing/test', commit_options) }.to raise_error('Invalid path')
    end
    it 'does not attempt to overwrite a file' do
      expect{ repository.mkdir('README.md', commit_options) }.to raise_error('Directory already exists as a file')
    end

    it 'does not attempt to overwrite a directory' do
      expect{ repository.mkdir('files', commit_options) }.to raise_error('Directory already exists')
    let(:attributes_path) { File.join(TEST_REPO_PATH, 'info/attributes') }
  describe '#diffable' do
    info_dir_path = attributes_path = File.join(TEST_REPO_PATH, 'info')
    attributes_path = File.join(info_dir_path, 'attributes')

    before(:all) do
      FileUtils.mkdir(info_dir_path) unless File.exist?(info_dir_path)
      File.write(attributes_path, "*.md -diff\n")
    end

    it "should return true for files which are text and do not have attributes" do
      blob = Gitlab::Git::Blob.find(
        repository,
        '33bcff41c232a11727ac6d660bd4b0c2ba86d63d',
        'LICENSE'
      )
      expect(repository.diffable?(blob)).to be_truthy
    end

    it "should return false for binary files which do not have attributes" do
      blob = Gitlab::Git::Blob.find(
        repository,
        '33bcff41c232a11727ac6d660bd4b0c2ba86d63d',
        'files/images/logo-white.png'
      )
      expect(repository.diffable?(blob)).to be_falsey
    end

    it "should return false for text files which have been marked as not being diffable in attributes" do
      blob = Gitlab::Git::Blob.find(
        repository,
        '33bcff41c232a11727ac6d660bd4b0c2ba86d63d',
        'README.md'
      )
      expect(repository.diffable?(blob)).to be_falsey
    end

    after(:all) do
      FileUtils.rm_rf(info_dir_path)
    end
  end

      @repo = Gitlab::Git::Repository.new(TEST_MUTABLE_REPO_PATH)
      create_remote_branch('joe', 'remote_branch', 'master')
  def create_remote_branch(remote_name, branch_name, source_branch_name)
    source_branch = @repo.branches.find { |branch| branch.name == source_branch_name }
    rugged = @repo.rugged