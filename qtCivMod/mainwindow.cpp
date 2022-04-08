#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include <QProcess>
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    this->m_ps = new QPowerShell(this);

    QObject::connect(this->m_ps, &QPowerShell::pipeFinished, this, &MainWindow::psFinished);
    this->m_currentPipe = this->m_ps->newPipe();

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::psFinished(QPowerShellPipeline *pipe, bool success, QPowerShellPipeline::QPSError error, const QByteArray &result)
{
    pipe = pipe;
    qDebug() << pipe->description();

    if (!success)
    {
        qDebug() << "Success:" << success;
        qDebug() << "Error Source: " << error.errorSource;
        qDebug() << "Error Message" << error.errorMessage;
    }
    else
    {
        qDebug() << "Success:" << success;
        qDebug() << "Result:\n" << result;
    }
}
void pipeFinished(QPowerShellPipeline *pipe, bool success, QPowerShellPipeline::QPSError error, const QByteArray &result);

void MainWindow::on_playButton_clicked()
{
        /*QProcess process;
        process.setWorkingDirectory("C:/Users/twins/Documents/git/UpdateGitModCiv");
        QString cmd("powershell");
        QStringList parameters{"majGitCiv.ps1"};
        process.start(cmd, parameters);
        C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
        C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\Users\twins\Desktop\majGitCiv.ps1
connect(p, &QProcess::readyReadStandardOutput, myClass, &MyClass::readyToRead);
process->start(path, commands);

*/
     if (this->m_currentPipe)
     {
         /*this->m_currentPipe->addParam("-ExecutionPolicy", "Bypass")
                 .addParam("-File", "C:\\Users\\twins\\Desktop\\majGitCiv.ps1");
*/
         this->m_currentPipe->addCommand("Start-Process steam://rungameid/289070");
                 //.addParam("-Path", "C:\\Users\\twins\\Documents\\git\\UpdateGitModCiv")
                 //.addCommand("Where-Object")
                 //.addParam("-FilterScript", "{$_.Extension -eq \".txt\"}")
                 //.addStatement("ECHO \"Well aren't you a Qt pie...\"")
                 //.addStatement("ECHO \";)\"");
         //this->m_currentPipe->setDescription("Number One!!!111");
         this->m_currentPipe->invoke();
     }
}

