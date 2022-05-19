#!/usr/bin/python3import argparseimport sysimport osimport timefrom multiprocessing import Pooldef parse_args():    parser = argparse.ArgumentParser(description='python multi thread runner', add_help=False)    parser.add_argument("-c", "--threads", type=int, default=1, dest='threads',                        help='How many threads will be running.')    parser.add_argument("-e", type=str, default=None, dest='cmd', help='command')    parser.add_argument("-s", "--sleep", type=int, default=0, dest='sleep',                        help='Sleep seconds between each transaction. ')    parser.add_argument('-h', '--help', dest='help', action='store_true', help='help information', default=False)    return parserdef command_line_args(args):    need_print_help = False if args else True    parser = parse_args()    args = parser.parse_args(args)    if args.help or need_print_help:        parser.print_help()        sys.exit(1)    if not args.cmd:        raise ValueError('The command must be specified and not empty.')    return argsdef ruuner(pid, cmd, sleep):    while True:        os.system(cmd)        time.sleep(sleep)if __name__ == '__main__':    args = command_line_args(sys.argv[1:])    max_threads = args.threads    print('Starting %s threads run %s' % (max_threads, args.cmd))    p = Pool(max_threads)    for i in range(max_threads):        p.apply_async(ruuner, args=(i, args.cmd, args.sleep))    p.close()    p.join()