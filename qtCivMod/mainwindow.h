#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "QPowerShell.h"
QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_playButton_clicked();
    void psFinished(QPowerShellPipeline *pipe, bool success, QPowerShellPipeline::QPSError error, const QByteArray &result);


private:
    Ui::MainWindow *ui;
    QPowerShell *m_ps;
    QPowerShellPipeline *m_currentPipe;
};
#endif // MAINWINDOW_H
