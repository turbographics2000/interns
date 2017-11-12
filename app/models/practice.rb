class Practice < ActiveRecord::Base
  has_many :artifacts
  has_many :learnings
  has_and_belongs_to_many :reports
  has_many :started_learnings,
    -> { where(status_cd: 0) },
    class_name: "Learning"
  has_many :completed_learnings,
    -> { where(status_cd: 1) },
    class_name: "Learning"
  has_many :started_users,
    through: :started_learnings,
    source:  :user
  has_many :completed_users,
    through: :completed_learnings,
    source:  :user
  belongs_to :category
  acts_as_list scope: :category

  validates :title, presence: true
  validates :description, presence: true
  validates :goal, presence: true

  def status(user)
    learnings = Learning.where(
      user_id:     user.id,
      practice_id: id
    )
    if learnings.blank?
      :not_complete
    else
      learnings.first.status
    end
  end

  def not_completed?(user)
    status_cds = Learning.statuses.values_at("complete")

    !Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def not_pending?(user)
    status_cds = Learning.statuses.values_at("pending")

    !Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def pending?(user)
    status_cds = Learning.statuses.values_at("pending")

    Learning.exists?(
      user:        user,
      practice_id: id,
      status_cd:   status_cds
    )
  end

  def exists_learning?(user)
    Learning.exists?(
      user:        user,
      practice_id: id
    )
  end

  def not_has_task_and_not_done?(user)
    not_completed?(user) && !task?
  end

  def exists_artifact?(user)
    Artifact.exists?(
      user_id:     user.id,
      practice_id: id
    )
  end

  def get_artifact(user)
    Artifact.find_by(
      user_id:     user.id,
      practice_id: id
    )
  end

  def complete(user)
    learning = Learning.find_or_create_by(
      user_id:     user.id,
      practice_id: id
    )
    learning.update!(status: :complete)
  end

  def pending(user)
    learning = Learning.find_or_create_by(
      user_id:     user.id,
      practice_id: id
    )
    learning.update!(status: :pending)
  end

  def all_text
    [title, description, goal].join("\n")
  end
end
