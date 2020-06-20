require 'rails_helper'

RSpec.describe 'Task', type: :system do
  # == let!で前処理化==
  let!(:task){ FactoryBot.create(:task) }
  # ===

  # === モジュールのshort_timeメソッドを使う ===
  include ApplicationHelper
  # ======
  describe 'Task一覧' do
    context '正常系' do
      it '一覧ページにアクセスした場合、Taskが表示されること' do
        # TODO: ローカル変数ではなく let を使用してください
        visit project_tasks_path(task)
        expect(page).to have_content task.title
        expect(Task.count).to eq 1
        expect(current_path).to eq project_tasks_path(task)
      end
      
      it 'Project詳細からTask一覧ページにアクセスした場合、Taskが表示されること' do
        # FIXME: テストが失敗するので修正してください
        visit project_path(task)
        click_on "View Todos"

        # 最後に開いたタブを指定
        within_window(windows.last) do
          expect(page).to have_content task.title
          expect(Task.count).to eq 1
          expect(current_path).to eq project_tasks_path(task)
        end
      end
    end
  end

  describe 'Task新規作成' do
    context '正常系' do
      it 'Taskが新規作成されること' do
        # TODO: ローカル変数ではなく let を使用してください
        visit project_tasks_path(task)
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
        visit project_tasks_path(task)
        expect(page).to have_content(task.title)
        expect(page).to have_content(task.status)
        expect(page).to have_content(short_time(task.deadline))
        expect(current_path).to eq project_tasks_path(task)
      end
    end
  end

  describe 'Task編集' do
    context '正常系' do
      it 'Taskを編集した場合、一覧画面で編集後の内容が表示されること' do
        # FIXME: テストが失敗するので修正してください
        visit edit_project_task_path(task, id: 1)
        fill_in 'Deadline', with: Time.current
        click_button 'Update Task'
        click_link 'Back'
        expect(page).to have_content(short_time(Time.current))
        # == short_timeメソッドを用いて検証 ==
        expect(current_path).to eq project_tasks_path(task)
      end

      it 'ステータスを完了にした場合、Taskの完了日に今日の日付が登録されること' do
        # TODO: ローカル変数ではなく let を使用してください
        visit edit_project_task_path(task, id: 1)
        select 'done', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('done')
        expect(page).to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(task, id: 1)
        
        # == idを指定しない場合、No route matches‥, missing required keys: [:id]でテストエラー ==
      end
      
      let!(:task) { create(:task, :done) }
      it '既にステータスが完了のタスクのステータスを変更した場合、Taskの完了日が更新されないこと' do
        # TODO: FactoryBotのtraitを利用してください
        visit edit_project_task_path(task, id: 1)
        select 'todo', from: 'Status'
        click_button 'Update Task'
        expect(page).to have_content('todo')
        expect(page).not_to have_content(Time.current.strftime('%Y-%m-%d'))
        expect(current_path).to eq project_task_path(task, id: 1)

        # == idを指定しない場合、No route matches‥, missing required keys: [:id]でテストエラー ==
      end
    end
  end

  describe 'Task削除' do
    context '正常系' do
      # FIXME: テストが失敗するので修正してください
      it 'Taskが削除されること' do
        visit project_tasks_path(task)
        click_link 'Destroy'
        page.driver.browser.switch_to.alert.accept
        expect(page).to have_content `Task was successfully destroyed`
        expect{Task.find(1)}.to raise_exception(ActiveRecord::RecordNotFound)
        expect(current_path).to eq project_tasks_path(task)
      end
    end
  end
end
