#include <iostream>
#include <cstdlib>
#include <unistd.h>

enum class CellItem {
    EMPTY,
    BLACK,
    WHITE
};

int main()
{
    int _, id;
    std::cin >> _ >> _ >> id;
    const int W = 6, H = 6;
    CellItem game_board[H][W] = {};

    while (true) {
        int turn, time;
        std::cin >> turn >> time;
        for (int y=0; y<H; y++) {
            for (int x=0; x<W; x++) {
                char cell;
                std::cin >> cell;
                if (cell == '-') {
                    game_board[y][x] = CellItem::EMPTY;
                } else if (cell == 'o') {
                    game_board[y][x] = CellItem::BLACK;
                } else {
                    game_board[y][x] = CellItem::WHITE;
                }
            }
        }

        sleep(2);
        int x = rand() % W, y = rand() % H;
        std::cout << x << " " << y << " " << rand()%4 << " " << rand()%2 << std::endl;
    }
}
