class ReportMailer < Iso2022jpMailer
  def report(to, report)
    recipients to
    subject base64("Rank Watcherからの#{report[:date]}のレポートです。")
    from "komagata@gmail.com"
    body :to => to, :report => report
  end
end
