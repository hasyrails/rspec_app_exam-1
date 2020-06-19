require 'rails_helper'

RSpec.describe 'Task', type: :system do
  # == let!で前処理化==
  let!(:project){ FactoryBot.create(:project) }
  let!(:task){ FactoryBot.create(:task, project_id: project.id) }
  # ===
  describe 'Task一覧' do
    context '正常系' do
      it '一覧ページにアクセスした場合、Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください
        visit project_tasks_path(project)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
        expect(current_path).to eq project_tasks_path(project)
      end
      
      it 'Project詳細からTask一覧ページにアクセスした場合、Taskが表示されること' do
        # FIXME: テストが失敗するので修正してください
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
        visit project_tasks_path(project)
        click_link 'New Task'
        fill_in 'Title', with: 'test'
        click_button 'Create Task'
        expect(page).to have_content('Task was successfully created.')
        expect(Task.count).to eq 2
        # == let!の前処理でtaskレコード予め1つあり＋１つ新規作成で2個になる ==
        expect(current_path).to eq '/projects/1/tasks/2'
        # == 詳細画面のtask_idを修正 ==
        # == id:1 → id:2 ==
      end
    end
  end

  describe 'Task詳細' do
    context '正常系' do
      it 'Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください
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
      it 'Taskを編集した場合、一覧画面で編集後の内容が表示されること' do
        # FIXME: テストが失敗するので修正してください
        visit edit_project_task_path(project, task)
        sleep 3
        fill_in 'Deadline', with: Time.current
        sleep 2
        click_button 'Update Task'
        sleep 2
        click_link 'Back'
        sleep 2
        expect(find('.task_list')).to have_content(Time.current.strftime('%-m/%d %-H:%M'))
        # == 日付表記の検証部分を修正 ==
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
      
      let!(:task) { create(:task, :done, project_id: project.id) }
      it '既にステータスが完了のタスクのステータスを変更した場合、Taskの完了日が更新されないこと' do
        # TODO: FactoryBotのtraitを利用してください
        visit edit_project_task_path(project, task)
        sleep 2
        select 'todo', from: 'Status'
        click_button 'Update Task'
        sleep 2
        expect(page).to have_content('todo')
        expect(page).not_to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(project, task)
      end
    end
  end

  describe 'Task削除' do
    context '正常系' do
      # FIXME: テストが失敗するので修正してください
      it 'Taskが削除されること' do
        visit project_tasks_path(project)
        sleep 2
        click_link 'Destroy'
        sleep 2
        page.driver.browser.switch_to.alert.accept
        sleep 2
        # expect(page).not_to have_content task.title
        # == 「ではない」ことを検証するのは範囲が広すぎる ==
        # == 特定の文言を対象とするテスト検証に変更 ==
        # == 削除成功のメッセージと重複（`Title`が含まれている） ==
        expect(page).not_to have_content task.title 
        expect(page).to have_content `Task was successfully destroyed`
        expect(Task.count).to eq 0
        expect(current_path).to eq project_tasks_path(project)
      end
    end
  end
end
