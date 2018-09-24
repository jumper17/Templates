//
//  ViewController.swift
//  Test
//
//  Created by Vyacheslav Pavlov on 22.09.2018.
//  Copyright © 2018 Vyacheslav Pavlov. All rights reserved.
//

import UIKit

class CustomPrintPageRenderer: UIPrintPageRenderer {
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    override init() {
        super.init()
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        self.setValue(pageFrame, forKey: "paperRect")
        self.setValue(pageFrame, forKey: "printableRect")
    }
}

class ViewController: UIViewController {
    
    var webView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        let pathToTalon = Bundle.main.path(forResource: "talon", ofType: "html")
        let htmlString = renderInvoice(pathToTalon!, "Vyacheslav", Date())
        webView.loadHTMLString(htmlString!, baseURL: nil)
        view.addSubview(webView)
    }
    
    func exportHTMLContentToPDF(_ htmlString: String) {
        // Сначала мы инициализируем CustomPrintPageRendererобъект, который мы будем использовать для выполнения фактического чертежа (что мы называем печатью).
        let printPageRenderer = CustomPrintPageRenderer()
        
        // Затем мы создаем экземпляр UIMarkupTextPrintFormatter объекта, в котором мы передаем содержимое HTML в качестве параметра для инициализации.
        let printFormatter = UIMarkupTextPrintFormatter(markupText: htmlString)
        
        // Форматирование страницы добавляется в объект рендеринга страницы печати
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        // фактический чертеж в формате PDF
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        let path = "\(NSTemporaryDirectory())test.pdf"
        pdfData!.write(toFile: path, atomically: true)
    }
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        // Создает графический контекст на основе PDF, который предназначен для указанного измененного объекта данных.
        UIGraphicsBeginPDFContextToData(data, .zero, nil)
        
        // Отмечает начало новой страницы в контексте PDF и настраивает ее с использованием значений по умолчанию.
        UIGraphicsBeginPDFPage()
        
        // Переопределено для рисования данной страницы содержимого для принтера.
        printPageRenderer.drawPage(at: 0, in: UIGraphicsGetPDFContextBounds())
        
        // Закрывает графический контекст PDF и выталкивает его из текущего стека контекста.
        UIGraphicsEndPDFContext()
        return data
    }
    
    func renderInvoice(_ path: String, _ name: String, _ date: Date) -> String? {
        let dateString = dateToString(date: date, format: "MMM d, h:mm a")
        do {
            var HTMLContent = try! String(contentsOfFile: path)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#NAME", with: name)
            HTMLContent = HTMLContent.replacingOccurrences(of: "#CREATION_TIME", with: dateString)
            return HTMLContent
        } catch {
            print("Unable to open and use HTML template files.")
            return nil
        }
    }
    
    func dateToString(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

}

