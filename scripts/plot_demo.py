"""Plot actual run_demo MAT outputs; requires NumPy, SciPy and Matplotlib."""
import argparse
from pathlib import Path
import numpy as np
from scipy.io import loadmat
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D


COLORS = ['#0072b2', '#009e73', '#d55e00']
plt.rcParams.update({'font.family': 'sans-serif', 'font.sans-serif': ['Arial', 'DejaVu Sans'],
                     'font.size': 10.5,
                     'svg.fonttype': 'none', 'axes.spines.top': False,
                     'axes.spines.right': False})


def draw_routes(data, routes, score, title, output):
    """Draw one route plan at a size suitable for a README or a narrow screen."""
    xy = np.asarray(data['allLocation'])
    demand = int(data['demand'])
    depots = np.asarray(data['vhcdepot'], dtype=int).ravel()
    capacities = np.asarray(data['vhccapacity'], dtype=int).ravel()
    fig, ax = plt.subplots(figsize=(5.7, 6.15))
    fig.subplots_adjust(left=.12, right=.97, top=.85, bottom=.20)
    fig.text(.12, .965, title, fontsize=15, weight='bold', va='top', color='#182b3a')
    fig.text(.12, .915, f'Weighted score {score:.6f}  ·  lower is better',
             fontsize=10.5, color='#52616d')
    for vehicle, route in enumerate(routes):
        nodes = np.asarray(route, dtype=int).ravel()
        if not nodes.size:
            continue
        points = xy[np.r_[depots[vehicle], nodes, depots[vehicle]] - 1]
        color = COLORS[vehicle % len(COLORS)]
        ax.plot(points[:, 0], points[:, 1], color=color, lw=1.8, alpha=.9)
        for start, end in zip(points[:-1], points[1:]):
            delta = end-start
            if np.linalg.norm(delta) == 0:
                continue
            ax.annotate('', xy=start+.57*delta, xytext=start+.43*delta,
                        arrowprops=dict(arrowstyle='->', color=color,
                                        lw=1.5, mutation_scale=12))
    ax.scatter(xy[:demand, 0], xy[:demand, 1], s=53, c='white',
               edgecolor='#253847', linewidths=1.3, zorder=4)
    ax.scatter(xy[demand:2*demand, 0], xy[demand:2*demand, 1], marker='^',
               s=61, c='white', edgecolor='#253847', linewidths=1.3, zorder=4)
    depot_ids = np.unique(depots) - 1
    ax.scatter(xy[depot_ids, 0], xy[depot_ids, 1], marker='s',
               s=70, c='#253847', zorder=4)
    for request in range(demand):
        for node, label in [(request, f'P{request+1}'),
                            (request+demand, f'D{request+1}')]:
            ax.annotate(label, xy[node], xytext=(0, 9), ha='center',
                        textcoords='offset points', fontsize=12,
                        color='#182b3a', zorder=5,
                        bbox=dict(facecolor='white', edgecolor='none', pad=.15, alpha=.9))
    for index, node in enumerate(depot_ids):
        ax.annotate(f'Depot {index+1}', xy[node], xytext=(0, -19), ha='center',
                    textcoords='offset points', fontsize=10, color='#253847')
    ax.set_aspect('equal')
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1.2, 10.2)
    ax.set_xticks([0, 2, 4, 6, 8, 10])
    ax.set_yticks([0, 2, 4, 6, 8, 10])
    ax.set_xlabel('Synthetic x coordinate (km)', fontsize=10)
    ax.set_ylabel('Synthetic y coordinate (km)', fontsize=10)
    ax.tick_params(labelsize=9)
    ax.grid(color='#e6ebef', linewidth=.6)
    ax.set_axisbelow(True)
    handles = [Line2D([0], [0], color=COLORS[v % len(COLORS)], lw=2,
                      label=f'V{v+1} · {capacity} seats')
               for v, capacity in enumerate(capacities)]
    fig.legend(handles=handles, loc='lower center', bbox_to_anchor=(.5, .075),
               ncol=3, frameon=False, fontsize=9, handlelength=1.7, columnspacing=1.1)
    node_handles = [Line2D([], [], marker=marker, color='none',
                           markerfacecolor=face, markeredgecolor='#253847', markersize=6,
                           label=label)
                    for marker, face, label in [('o', 'white', 'Pickup (P)'),
                                                 ('^', 'white', 'Drop-off (D)'),
                                                 ('s', '#253847', 'Depot')]]
    fig.legend(handles=node_handles, loc='lower center', bbox_to_anchor=(.5, .025),
               ncol=3, frameon=False, fontsize=9, handlelength=1, columnspacing=1.3)
    output.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output, facecolor='white', metadata={'Date': None})
    fig.savefig(output.with_suffix('.png'), facecolor='white', dpi=180)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=Path, default=Path('results/demo'))
    parser.add_argument('--output', type=Path, default=Path('examples/demo_routes.svg'))
    args = parser.parse_args()
    data = loadmat(args.input / 'instance.mat', simplify_cells=True)['data']
    run = loadmat(args.input / 'result.mat', simplify_cells=True)['result']
    initial_output = args.output.with_name(args.output.stem + '_initial' + args.output.suffix)
    draw_routes(data, data['inisolution1'], run['initialCost'], 'Initial route plan', initial_output)
    draw_routes(data, run['bestSolution'], run['bestCost'], 'Best visited route plan', args.output)
    print(initial_output)
    print(args.output)


if __name__ == '__main__':
    main()
