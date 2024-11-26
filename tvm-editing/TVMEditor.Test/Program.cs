using System;
using System.IO;
using TVMEditor.Test.Experiments;
using System.Diagnostics;
namespace TVMEditor.Test
{
    class Program
    {
        static void Main(string[] args)
        {
            var inputDir = "Data/pent";
            var outputDir = $"output";
            if (args.Length > 0)
                inputDir = args[0];
            if (args.Length > 1)
                outputDir = args[1];

            if (!Directory.Exists(outputDir))
                Directory.CreateDirectory(outputDir);
            Stopwatch stopwatch = Stopwatch.StartNew();
            //Levi.Run(inputDir, outputDir);
            //Dancer.Run(inputDir, outputDir);
            //Basketball.Run(inputDir, outputDir);
            //Mitch.Run(inputDir, outputDir);
            Thomas.Run(inputDir, outputDir);
            /*TranslationVectorPentExperiment1.Run(inputDir, outputDir);
            TransformationMatrixPentExperiment1.Run(inputDir, outputDir);
            VectorQuaternionPentExperiment1.Run(inputDir, outputDir);
            DualQuaternionPentExperiment1.Run(inputDir, outputDir);

            TranslationVectorPentExperiment2.Run(inputDir, outputDir);
            TransformationMatrixPentExperiment2.Run(inputDir, outputDir);
            VectorQuaternionPentExperiment2.Run(inputDir, outputDir);
            DualQuaternionPentExperiment2.Run(inputDir, outputDir);

            TranslationVectorPentExperiment3.Run(inputDir, outputDir);
            TransformationMatrixPentExperiment3.Run(inputDir, outputDir);
            VectorQuaternionPentExperiment3.Run(inputDir, outputDir);
            DualQuaternionPentExperiment3.Run(inputDir, outputDir);*/
            stopwatch.Stop();
            Console.WriteLine($"Elapsed time: {stopwatch.Elapsed.TotalSeconds:F2} seconds");
        }
    }
}
