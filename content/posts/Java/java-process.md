---
title: Java 执行 cmd 命令
date: '2019-10-30 00:00:00'
tags:
- Java
---

# Java 使用 cmd 调用进程

```java
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.Timer;
import java.util.TimerTask;

public class ProcCmd {
    private String charsetName = "UTF-8";
    private String logFilePath = "D:/logs";
    private Long timeout = (long) (1000 * 60 * 3);
    private boolean isSuccess = true;

    private static class Worker extends Thread {
        private final Process process;
        private Integer exit;

        private Worker(Process process) {
            this.process = process;
        }

        public void run() {
            try {
                exit = process.waitFor();
            } catch (InterruptedException ignore) {
                return;
            }
        }
    }

    public boolean execByTimeout(String commandstr) {
        System.out.println("开始时间：" + new Date());
        Runtime runtime = Runtime.getRuntime();
        Process process = null;
        try {
            process = runtime.exec(commandstr);
            outputLog(process, false, false);

            Worker worker = new Worker(process);
            worker.start();
            worker.join(this.timeout);
            System.out.println("worker.exit =====" + worker.exit);
            if (worker.exit != null) {
                if (isSuccess) {
                    writeComLog("Process out :执行成功...");
                } else {
                    writeComLog("Process out :执行过程中有错误发生...");
                }
                return isSuccess;
            } else {
                writeComLog("Process err :执行超时：" + commandstr);
                // 超时
                return false;
            }
        } catch (IOException e) {
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            if (process != null) {
                /*	try {
					Thread.sleep(3000L);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}*/
                System.out.println("结束时间：" + new Date());
                process.destroy();
            }
        }

        return false;
    }


    public boolean exec(String commandstr) {
        Process process = null;
        try {
            process = Runtime.getRuntime().exec(commandstr);

            outputLog(process, true, true);

            // 阻塞线程，等待命令执行完毕
            process.waitFor();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            if (process != null) {
                process.destroy();
            }
        }
    }

    /**
     * 记录日志内容
     */
    @SuppressWarnings("static-access")
    public synchronized void writeComLog(String str) {
        Calendar c = GregorianCalendar.getInstance();
        logFilePath = logFilePath +"/"+ "databackup-"+c.get(c.YEAR)+ fillZero(1+c.get(c.MONTH)+"", 2) + ".log";
        String datetime = null;
        try {

            datetime = "" + c.get(c.YEAR) + "-"
                + fillZero(1 + c.get(c.MONTH) + "", 2) + "-"
                + fillZero("" + c.get(c.DAY_OF_MONTH), 2) + " "
                + fillZero("" + c.get(c.HOUR), 2) + ":"
                + fillZero("" + c.get(c.MINUTE), 2) + ":"
                + fillZero("" + c.get(c.SECOND), 2);


            str = "[" + datetime + "] " + str;
            System.out.println(str);

            //写日志
            writeLog(str);

        } catch (Exception e) {
            System.out.println("Error");
        }
    }

    private void outputLog(final Process pr, boolean printOutput, boolean printError) {
        if (printOutput) {
            new Timer().schedule(new TimerTask() {

                @Override
                public void run() {

                    BufferedReader br_in = null;
                    try {
                        br_in = new BufferedReader(new InputStreamReader(pr.getInputStream(), charsetName));
                        String buff = null;
                        String lastBuff = null;
                        while ((buff = br_in.readLine()) != null) {

                            if (buff != null && !buff.equals(lastBuff)) {
                                lastBuff = buff;
                                writeComLog("Process out :" + buff);
                            }

                            try {
                                Thread.sleep(100);
                            } catch (Exception e) {
                            }
                        }
                        br_in.close();


                    } catch (IOException ioe) {
                        System.out.println("Exception caught printing process output.");
                        ioe.printStackTrace();
                    } finally {
                        try {
                            br_in.close();
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                }

            }, 100);
        }

        if (printError) {
            new Timer().schedule(new TimerTask() {

                @Override
                public void run() {
                    BufferedReader br_err = null;

                    try {
                        br_err = new BufferedReader(new InputStreamReader(pr.getErrorStream(), charsetName));
                        String buff = null;
                        String lastBuff = null;
                        while ((buff = br_err.readLine()) != null) {

                            if (buff != null && !buff.equals(lastBuff)) {
                                lastBuff = buff;
                                writeComLog("Process err :" + buff);
                                isSuccess = false;

                            }
                            try {
                                Thread.sleep(100);
                            } catch (Exception e) {

                            }

                        }
                        br_err.close();
                    } catch (IOException ioe) {
                        System.out.println("Exception caught printing process error.");
                        ioe.printStackTrace();
                    } finally {
                        try {
                            br_err.close();
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }
                }

            }, 100);
        }
    }

    private void writeLog(String str) {
        if (logFilePath == null) {
            return;
        }

        BufferedWriter bufOut = null;

        try {
            File f = new File(logFilePath);
            if (f.exists() == true) {
                bufOut = new BufferedWriter(new FileWriter(f, true));
            } else {
                bufOut = new BufferedWriter(new FileWriter(f));
            }
            bufOut.write(str + "\n");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (bufOut != null) {
                try {
                    bufOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void writeLog(String logPath, String str) {
        if (logPath == null) {
            return;
        }

        BufferedWriter bufOut = null;

        try {
            File f = new File(logPath);
            if (f.exists() == true) {
                bufOut = new BufferedWriter(new FileWriter(f, true));
            } else {
                bufOut = new BufferedWriter(new FileWriter(f));
            }
            bufOut.write(str + "\n");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (bufOut != null) {
                try {
                    bufOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /*右对齐左补零*/
    static String fillZero(String str, int len) {
        int tmp = str.length();
        int t;
        String str1 = str;
        if (tmp >= len)
            return str1;
        t = len - tmp;
        for (int i = 0; i < t; i++)
            str1 = "0" + str1;
        return str1;
    }


        public String getLogFilePath() {
        return logFilePath;
    }

    public void setLogFilePath(String logFilePath) {
        this.logFilePath = logFilePath;
    }

    public String getCharsetName() {
        return charsetName;
    }

    public void setCharsetName(String charsetName) {
        this.charsetName = charsetName;
    }

    public Long getTimeout() {
        return timeout;
    }

    public void setTimeout(Long timeout) {
        this.timeout = timeout;
    }
}
```
