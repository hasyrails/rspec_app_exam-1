require 'rails_helper'

RSpec.describe 'Task', type: :system do
  describe 'Task一覧' do
    context '正常系' do
      it '一覧ページにアクセスした場合、Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit project_tasks_path(project)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
        expect(current_path).to eq project_tasks_path(project)
      end
      
      fit 'Project詳細からTask一覧ページにアクセスした場合、Taskが表示されること' do
        # FIXME: テストが失敗するので修正してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit project_path(project)
        sleep 3
        click_on "View Todos"
        sleep 3

        # 最後に開いたタブを指定
        within_window(windows.last) do
          expect(page).to have_content task.title
          expect(Task.count).to eq 1
          expect(current_path).to eq project_tasks_path(project)
        end

        # == 修正前では何が起こっているか
        # expect(page).to have_content project.name
          # == project詳細ページへアクセスしているためprojectの名前が表示されている ==
        # expect(Task.count).to eq 1
        # expect(current_path).to eq project_path(project)
         # == Task一覧画面を表示すべきところを、project詳細画面へアクセスしている ==
        # ==
      end
    end
  end

  describe 'Task新規作成' do
    context '正常系' do
      it 'Taskが新規作成されること' do
        # TODO: ローカル変数ではなく let を使用してください
        project = FactoryBot.create(:project)
        visit project_tasks_path(project)
        click_link 'New Task'
        fill_in 'Title', with: 'test'
        click_button 'Create Task'
        expect(page).to have_content('Task was successfully created.')
        expect(Task.count).to eq 1
        expect(current_path).to eq '/projects/1/tasks/1'
      end
    end
  end

  describe 'Task詳細' do
    context '正常系' do
      it 'Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit project_task_path(project, task)
        expect(page).to have_content(task.title)
        expect(page).to have_content(task.status)
        expect(page).to have_content(task.deadline.strftime('%Y-%m-%d %H:%M'))
        expect(current_path).to eq project_task_path(project, task)
      end
    end
  end

  describe 'Task編集' do
    context '正常系' do
      xit 'Taskを編集した場合、一覧画面で編集後の内容が表示されること' do
        # FIXME: テストが失敗するので修正してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit edit_project_task_path(project, task)
        fill_in 'Deadline', with: Time.current
        click_button 'Update Task'
        click_link 'Back'
        expect(find('.task_list')).to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_tasks_path(project)
      end

      it 'ステータスを完了にした場合、Taskの完了日に今日の日付が登録されること' do
        # TODO: ローカル変数ではなく let を使用してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit edit_project_task_path(project, task)
        select 'done', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('done')
        expect(page).to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(project, task)
      end

      it '既にステータスが完了のタスクのステータスを変更した場合、Taskの完了日が更新されないこと' do
        # TODO: FactoryBotのtraitを利用してください
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id, status: :done, completion_date: Time.current.yesterday)
        visit edit_project_task_path(project, task)
        select 'todo', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('todo')
        expect(page).not_to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(project, task)
      end
    end
  end

  describe 'Task削除' do
    context '正常系' do
      # FIXME: テストが失敗するので修正してください
      xit 'Taskが削除されること' do
        project = FactoryBot.create(:project)
        task = FactoryBot.create(:task, project_id: project.id)
        visit project_tasks_path(project)
        click_link 'Destroy'
        page.driver.browser.switch_to.alert.accept
        expect(page).not_to have_content task.title
        expect(Task.count).to eq 0
        expect(current_path).to eq project_tasks_path(project)
      end
    end
  end
end
