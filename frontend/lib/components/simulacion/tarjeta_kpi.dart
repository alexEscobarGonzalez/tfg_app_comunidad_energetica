import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TarjetaKPI extends StatelessWidget {
  final String titulo;
  final String valor;
  final String? unidad;
  final IconData icono;
  final Color? colorIcono;
  final Color? colorValor;
  final String? subtitulo;
  final double? tendencia;
  final bool mostrarTendencia;

  const TarjetaKPI({
    Key? key,
    required this.titulo,
    required this.valor,
    this.unidad,
    required this.icono,
    this.colorIcono,
    this.colorValor,
    this.subtitulo,
    this.tendencia,
    this.mostrarTendencia = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final efectiveColorIcono = colorIcono ?? Theme.of(context).primaryColor;
    final efectiveColorValor = colorValor ?? Theme.of(context).primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              efectiveColorIcono.withOpacity(0.05),
              efectiveColorIcono.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Encabezado con icono y título
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: efectiveColorIcono.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icono,
                    color: efectiveColorIcono,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                                  Expanded(
                    child: Text(
                      titulo,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (mostrarTendencia && tendencia != null)
                  _buildTendenciaWidget(),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Valor principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    valor,
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: efectiveColorValor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unidad != null) ...[
                  SizedBox(width: 4.w),
                  Text(
                    unidad!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            
            // Subtítulo opcional
            if (subtitulo != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitulo!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTendenciaWidget() {
    if (tendencia == null) return const SizedBox.shrink();
    
    final esPositiva = tendencia! >= 0;
    final color = esPositiva ? Colors.green : Colors.red;
    final icono = esPositiva ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, color: color, size: 12.sp),
          SizedBox(width: 2.w),
          Text(
            '${tendencia!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class GridKPIs extends StatelessWidget {
  final List<TarjetaKPI> kpis;
  final int columnCount;
  final double spacing;

  const GridKPIs({
    Key? key,
    required this.kpis,
    this.columnCount = 2,
    this.spacing = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kpis.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: 1.2,
        crossAxisSpacing: spacing.w,
        mainAxisSpacing: spacing.h,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) => kpis[index],
    );
  }
} 